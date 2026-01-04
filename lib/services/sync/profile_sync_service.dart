import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_service.dart';
import '../database/app_database.dart';

final profileSyncServiceProvider = Provider<ProfileSyncService>((ref) {
  return ProfileSyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(apiServiceProvider),
  );
});

class ProfileSyncService {
  ProfileSyncService(this._db, this._api);
  final AppDatabase _db;
  final ApiService _api;

  /// Get all profiles that haven't been synced to backend yet
  Future<List<Profile>> getUnsyncedProfiles() async {
    return (_db.select(
      _db.profiles,
    )..where((p) => p.backendProfileId.isNull())).get();
  }

  /// Sync a single profile to the backend
  Future<bool> syncProfile(Profile profile) async {
    try {
      final selfieFile = profile.selfieLocalPath != null
          ? File(profile.selfieLocalPath!)
          : null;

      if (selfieFile == null || !selfieFile.existsSync()) {
        return false;
      }

      final payload = <String, dynamic>{
        'id': profile.id,
        'name': profile.name,
        'contact': profile.contact,
        'age': profile.age,
        'aadhaar': profile.aadhaar,
        'livenessStatus': profile.livenessStatus ?? 'PASSED',
        'livenessScore': profile.livenessScore ?? 0.0,
        'livenessAttemptedAt':
            profile.livenessAttemptedAt?.toUtc().toIso8601String() ??
            DateTime.now().toUtc().toIso8601String(),
        'location': profile.location ?? '',
        'mobileVerificationId': profile.mobileVerificationId ?? '',
        'creationTime': profile.createdAt.toUtc().toIso8601String(),
      };

      final response = await _api.createProfile(
        selfieFile: selfieFile,
        payload: payload,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final backendId = data['id'] as String?;

        // Update profile with backend ID
        await (_db.update(_db.profiles)..where((p) => p.id.equals(profile.id)))
            .write(ProfilesCompanion(backendProfileId: Value(backendId)));

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Sync all unsynced profiles
  Future<int> syncAllProfiles() async {
    final unsyncedProfiles = await getUnsyncedProfiles();
    int syncedCount = 0;

    for (final profile in unsyncedProfiles) {
      final success = await syncProfile(profile);
      if (success) {
        syncedCount++;
      }
    }

    return syncedCount;
  }

  /// Check if there are any unsynced profiles
  Future<bool> hasUnsyncedProfiles() async {
    final count = await (_db.select(
      _db.profiles,
    )..where((p) => p.backendProfileId.isNull())).get();
    return count.isNotEmpty;
  }
}
