import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../core/providers/app_state_provider.dart';
import '../models/task/captured_photo.dart';
import '../models/task/checklist_item.dart';
import '../models/task/task_enums.dart';
import '../models/task/task_meta_data.dart';
import '../services/database/app_database.dart';
import '../core/enums/location_status.dart';

class TaskCaptureState {
  const TaskCaptureState({
    this.task,
    this.isLoading = true,
    this.metaData,
    this.checklist = const [],
    this.capturedPhotos = const [],
    this.observations = '',
    this.error,
    this.submissionId,
    this.locationStatus = LocationStatus.idle,
    this.currentLat,
    this.currentLng,
    this.centerLat,
    this.centerLng,
    this.distanceFromCenter,
  });

  final Task? task;
  final bool isLoading;
  final TaskMetaData? metaData;
  final List<ChecklistItem> checklist;
  final List<CapturedPhoto> capturedPhotos;
  final String observations;
  final String? error;
  final String? submissionId;
  final LocationStatus locationStatus;
  final double? currentLat;
  final double? currentLng;
  final double? centerLat;
  final double? centerLng;
  final double? distanceFromCenter;

  TaskCaptureState copyWith({
    Task? task,
    bool? isLoading,
    TaskMetaData? metaData,
    List<ChecklistItem>? checklist,
    List<CapturedPhoto>? capturedPhotos,
    String? observations,
    String? error,
    String? submissionId,
    LocationStatus? locationStatus,
    double? currentLat,
    double? currentLng,
    double? centerLat,
    double? centerLng,
    double? distanceFromCenter,
  }) {
    return TaskCaptureState(
      task: task ?? this.task,
      isLoading: isLoading ?? this.isLoading,
      metaData: metaData ?? this.metaData,
      checklist: checklist ?? this.checklist,
      capturedPhotos: capturedPhotos ?? this.capturedPhotos,
      observations: observations ?? this.observations,
      error: error,
      submissionId: submissionId ?? this.submissionId,
      locationStatus: locationStatus ?? this.locationStatus,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      distanceFromCenter: distanceFromCenter ?? this.distanceFromCenter,
    );
  }

  String get formattedDistance {
    if (distanceFromCenter == null) return '';
    if (distanceFromCenter! < 1000) {
      return '${distanceFromCenter!.round()}m';
    }
    return '${(distanceFromCenter! / 1000).toStringAsFixed(1)}km';
  }

  /// Geofence radius in meters (500m is typical)
  static const double geofenceRadius = 500.0;

  /// Whether the user is inside the geofence (within 500m of center)
  bool get isInsideGeofence {
    if (distanceFromCenter == null) return false;
    return distanceFromCenter! <= geofenceRadius;
  }

  /// Whether this is an IMAGE type task (show photo capture)
  bool get isImageTask => task?.taskType == 'IMAGE';

  /// Whether this is a CHECKLIST type task (show checklist questions)
  bool get isChecklistTask => task?.taskType == 'CHECKLIST';

  /// Count of answered checklist items
  int get answeredCount => checklist.where((item) => item.value != 'NA').length;

  /// Required number of images for this task (default: 1)
  /// TODO: Parse from task metaData when API provides no-img-cnt field
  int get requiredImageCount => 1;

  /// Whether the image limit has been reached
  bool get hasReachedImageLimit => capturedPhotos.length >= requiredImageCount;

  /// Whether all required fields are complete
  bool get canComplete {
    if (isImageTask) {
      // Must have exactly the required number of images
      return capturedPhotos.length == requiredImageCount;
    } else if (isChecklistTask) {
      return checklist.isNotEmpty &&
          checklist
              .where((item) => item.required)
              .every((item) => item.value != 'NA');
    }
    return true;
  }
}

class TaskCaptureViewModel extends Notifier<TaskCaptureState> {
  final _imagePicker = ImagePicker();

  @override
  TaskCaptureState build() {
    return const TaskCaptureState();
  }

  /// Load task by its UUID (not the CODE)
  void loadTask(String taskUuid) {
    // CRITICAL: Reset state completely before loading new task
    // This prevents cross-contamination of observations/photos between tasks
    state = const TaskCaptureState(isLoading: true);

    final appState = ref.read(appStateProvider);

    // Find task by UUID (task.id), NOT by CODE (task.taskId)
    final task = appState.tasks.where((t) => t.id == taskUuid).firstOrNull;

    if (task == null) {
      state = state.copyWith(isLoading: false, error: 'Task not found');
      return;
    }

    // Parse metaData from JSON
    TaskMetaData? metaData;
    if (task.metaDataJson != null) {
      try {
        final metaDataMap = jsonDecode(task.metaDataJson!);
        metaData = TaskMetaData.fromJson(metaDataMap);
      } catch (e) {
        print('Error parsing metaData: $e');
      }
    }

    // Parse checklist from JSON
    List<ChecklistItem> checklist = [];
    if (task.checklistJson != null) {
      try {
        final List<dynamic> checklistList = jsonDecode(task.checklistJson!);
        checklist = checklistList
            .map((e) => ChecklistItem.fromJson(e))
            .toList();
      } catch (e) {
        print('Error parsing checklist: $e');
      }
    }

    // Check for existing submission by task UUID first, then by CODE (backward compat)
    var submission = appState.taskSubmissions
        .where((s) => s.taskId == task.id)
        .firstOrNull;

    // Fallback: try by CODE for old submissions
    submission ??= appState.taskSubmissions
        .where((s) => s.taskId == task.taskId)
        .firstOrNull;

    String observations = '';
    List<CapturedPhoto> capturedPhotos = [];
    String? submissionId;

    if (submission != null) {
      submissionId = submission.id;
      observations = submission.observations ?? '';

      // Load checklist answers from submission
      try {
        final List<dynamic> answersJson = jsonDecode(
          submission.verificationAnswers,
        );
        checklist = checklist.map((item) {
          final answerData = answersJson.firstWhere(
            (a) => a['id'] == item.id,
            orElse: () => null,
          );
          if (answerData != null) {
            return item.copyWith(value: answerData['value']);
          }
          return item;
        }).toList();
      } catch (e) {
        print('Error parsing verification answers: $e');
      }

      // Load captured photos
      try {
        final List<dynamic> photosJson = jsonDecode(submission.imagePaths);
        capturedPhotos = photosJson.map((p) {
          return CapturedPhoto(imagePath: p.toString());
        }).toList();
      } catch (e) {
        print('Error parsing captured photos: $e');
      }
    }

    state = state.copyWith(
      task: task,
      isLoading: false,
      metaData: metaData,
      checklist: checklist,
      observations: observations,
      capturedPhotos: capturedPhotos,
      submissionId: submissionId,
      centerLat: appState.centerLat,
      centerLng: appState.centerLng,
    );

    _detectLocation();
  }

  Future<void> _detectLocation() async {
    state = state.copyWith(locationStatus: LocationStatus.detecting);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(locationStatus: LocationStatus.error);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(locationStatus: LocationStatus.error);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(locationStatus: LocationStatus.error);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      double? distance;
      if (state.centerLat != null && state.centerLng != null) {
        distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          state.centerLat!,
          state.centerLng!,
        );
      }

      state = state.copyWith(
        locationStatus: LocationStatus.detected,
        currentLat: position.latitude,
        currentLng: position.longitude,
        distanceFromCenter: distance,
      );
    } catch (e) {
      state = state.copyWith(locationStatus: LocationStatus.error);
    }
  }

  Future<void> retryLocationDetection() async {
    await _detectLocation();
  }

  void setChecklistAnswer(int index, String value) {
    final updatedList = List<ChecklistItem>.from(state.checklist);
    updatedList[index] = updatedList[index].copyWith(value: value);
    state = state.copyWith(checklist: updatedList);
  }

  void updateObservations(String text) {
    state = state.copyWith(observations: text);
  }

  Future<void> capturePhoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return;

      addPhoto(CapturedPhoto(imagePath: image.path));
    } catch (e) {
      state = state.copyWith(error: 'Failed to capture photo');
    }
  }

  void addPhoto(CapturedPhoto photo) {
    state = state.copyWith(capturedPhotos: [...state.capturedPhotos, photo]);
  }

  void removePhoto(int index) {
    final updatedPhotos = List<CapturedPhoto>.from(state.capturedPhotos);
    updatedPhotos.removeAt(index);
    state = state.copyWith(capturedPhotos: updatedPhotos);
  }

  Future<bool> completeTask() async {
    if (state.task == null) return false;

    try {
      final db = ref.read(appDatabaseProvider);
      // Use the task UUID, NOT the CODE
      final taskUuid = state.task!.id;

      // Serialize checklist answers to JSON
      final checklistAnswersJson = jsonEncode(
        state.checklist
            .map(
              (item) => {
                'id': item.id,
                'question': item.question,
                'value': item.value,
              },
            )
            .toList(),
      );

      // Serialize image paths to JSON
      final imagePathsJson = jsonEncode(
        state.capturedPhotos.map((photo) => photo.imagePath).toList(),
      );

      final latitude = state.currentLat;
      final longitude = state.currentLng;

      if (state.submissionId != null) {
        // Update existing record
        await (db.update(
          db.taskSubmissions,
        )..where((t) => t.id.equals(state.submissionId!))).write(
          TaskSubmissionsCompanion(
            observations: Value(state.observations),
            verificationAnswers: Value(checklistAnswersJson),
            imagePaths: Value(imagePathsJson),
            status: Value(SyncStatus.unsynced.toDbValue),
            submittedAt: Value(DateTime.now()),
            latitude: Value(latitude),
            longitude: Value(longitude),
          ),
        );
      } else {
        // Insert new record with task UUID (not CODE)
        final newSubmissionId = const Uuid().v4();
        await db
            .into(db.taskSubmissions)
            .insert(
              TaskSubmissionsCompanion.insert(
                id: newSubmissionId,
                taskId: taskUuid, // Store UUID, not CODE
                observations: Value(state.observations),
                verificationAnswers: checklistAnswersJson,
                imagePaths: imagePathsJson,
                status: Value(SyncStatus.unsynced.toDbValue),
                latitude: Value(latitude),
                longitude: Value(longitude),
              ),
            );
      }

      // Update task status to SUBMITTED (query by UUID, not CODE)
      await (db.update(db.tasks)..where((t) => t.id.equals(taskUuid))).write(
        TasksCompanion(taskStatus: Value(TaskStatus.submitted.toDbValue)),
      );

      // Refresh app state
      await ref.read(appStateProvider.notifier).loadFromDatabase();

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final taskCaptureViewModelProvider =
    NotifierProvider<TaskCaptureViewModel, TaskCaptureState>(
      TaskCaptureViewModel.new,
    );
