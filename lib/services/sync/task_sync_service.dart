import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/task/task_enums.dart'; // Correct path
import '../api/api_service.dart';
import '../database/app_database.dart';
import '../../models/auth/center.dart' as model; // Correct path

final taskSyncServiceProvider = Provider<TaskSyncService>((ref) {
  return TaskSyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(apiServiceProvider),
  );
});

class TaskSyncService {
  TaskSyncService(this._db, this._api);

  final AppDatabase _db;
  final ApiService _api;

  /// Get all tasks that haven't been synced to backend yet
  Future<List<TaskSubmission>> getUnsyncedTasks() async {
    return (_db.select(
      _db.taskSubmissions,
    )..where((t) => t.status.equals(SyncStatus.unsynced.toDbValue))).get();
  }

  /// Sync a single task to the backend
  Future<bool> syncTask(TaskSubmission submission) async {
    try {
      // 1. Gather Device Info & App Version
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String imei = 'Unknown';
      String modelDevice =
          'Unknown'; // Renamed to avoid name clash with model import
      String brand = 'Unknown';

      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          modelDevice = androidInfo.model;
          brand = androidInfo.brand;
          imei = androidInfo.id; // Using ID as identifier
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          modelDevice = iosInfo.name;
          brand = 'Apple';
          imei = iosInfo.identifierForVendor ?? 'Unknown';
        }
      } catch (e) {
        // Fallback or log error
      }

      // 2. Fetch Task and Profile Info
      String profileId = 'Unknown';
      String apiTaskId = submission.taskId;

      // Try to find task by UUID first (new format), then by CODE (old format)
      var task = await (_db.select(
        _db.tasks,
      )..where((t) => t.id.equals(submission.taskId))).getSingleOrNull();

      // Fallback: if not found by UUID, try by CODE (for old submissions)
      task ??= await (_db.select(
        _db.tasks,
      )..where((t) => t.taskId.equals(submission.taskId))).getSingleOrNull();

      if (task != null) {
        final foundTask = task; // Local non-null reference
        apiTaskId = foundTask.id; // Use the UUID for the API

        final profile =
            await (_db.select(_db.profiles)
                  ..where((p) => p.shiftId.equals(foundTask.shiftId))
                  ..limit(1))
                .getSingleOrNull();
        profileId = profile?.backendProfileId ?? profile?.id ?? 'Unknown';
      }

      // 3. Gather Location & Center Info (from stored session)
      final session = await (_db.select(
        _db.sessions,
      )..limit(1)).getSingleOrNull();
      double distFromCenter = 0;
      String fenceStatus = 'OUTSIDE';
      String locationName = 'Unknown Location';

      if (session?.centerJson != null) {
        try {
          final centerMap = jsonDecode(session!.centerJson!);
          final center = model.Center.fromJson(centerMap);
          locationName = center.name;

          if (center.lat != null &&
              center.lng != null &&
              submission.latitude != null &&
              submission.longitude != null) {
            final centerLat = double.tryParse(center.lat!);
            final centerLng = double.tryParse(center.lng!);

            if (centerLat != null && centerLng != null) {
              distFromCenter = Geolocator.distanceBetween(
                submission.latitude!,
                submission.longitude!,
                centerLat,
                centerLng,
              );

              // Determine fence status (e.g., inside 500m radius)
              fenceStatus = distFromCenter <= 500 ? 'INSIDE' : 'OUTSIDE';
            }
          }
        } catch (e) {
          // Error parsing center info
        }
      }

      // 4. Prepare Images
      List<File> files = [];
      if (submission.imagePaths != null) {
        try {
          final List<dynamic> paths = jsonDecode(submission.imagePaths!);
          files = paths
              .map((e) => File(e.toString()))
              .where((f) => f.existsSync())
              .toList();
        } catch (e) {
          // Handle parsing error
        }
      }

      // 5. Prepare Payload
      final payload = <String, dynamic>{
        'taskMessage': submission.observations ?? '',
        'submittedAt': submission.submittedAt.toUtc().toIso8601String(),
        'fenceStatus': fenceStatus,
        'distFromCenter': distFromCenter,
        'location': locationName,
      };

      // 5a. Add checklist data for CHECKLIST type tasks
      if (task != null && task.taskType == 'CHECKLIST') {
        try {
          final List<dynamic> checklistAnswers =
              jsonDecode(submission.verificationAnswers);
          payload['checklist'] = checklistAnswers;
        } catch (e) {
          // Failed to parse checklist, proceed without it
        }
      }

      // 6. Prepare Headers
      final headers = {
        'Accept': '*/*',
        'x-lat': submission.latitude?.toString() ?? '0.0',
        'x-lng': submission.longitude?.toString() ?? '0.0',
        'x-imei': imei,
        'x-mod': modelDevice,
        'x-brd': brand,
        'x-appv': packageInfo.version,
        'x-profileid': profileId,
      };

      // 7. Call API
      final response = await _api.updateTask(
        taskId: apiTaskId, // Use the resolved UUID
        files: files,
        payload: payload,
        headers: headers,
      );

      if (response.isSuccess) {
        // Mark as synced locally
        await (_db.update(
          _db.taskSubmissions,
        )..where((t) => t.id.equals(submission.id))).write(
          TaskSubmissionsCompanion(
            status: Value(SyncStatus.synced.toDbValue),
            syncedAt: Value(DateTime.now()),
          ),
        );
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  /// Sync all unsynced tasks
  Future<int> syncAllTasks() async {
    final unsyncedTasks = await getUnsyncedTasks();
    int syncedCount = 0;

    for (final task in unsyncedTasks) {
      final success = await syncTask(task);
      if (success) {
        syncedCount++;
      }
    }

    return syncedCount;
  }
}
