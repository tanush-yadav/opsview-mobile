import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../core/providers/app_state_provider.dart';
import '../models/task/captured_photo.dart';
import '../models/task/checklist_item.dart';
import '../models/task/image_checklist_entry.dart';
import '../models/task/task_enums.dart';
import '../models/task/task_meta_data.dart';
import '../services/database/app_database.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/file_utils.dart';
import '../core/enums/location_status.dart';

class NewSubmissionState {
  const NewSubmissionState({
    this.task,
    this.isLoading = true,
    this.metaData,
    this.checklistTemplate = const [],
    this.capturedPhotos = const [],
    this.imageChecklistEntries = const [],
    this.observations = '',
    this.error,
    this.isSubmitting = false,
    this.isSubmitted = false,
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
  final List<ChecklistItem> checklistTemplate;
  final List<CapturedPhoto> capturedPhotos;
  final List<ImageChecklistEntry> imageChecklistEntries;
  final String observations;
  final String? error;
  final bool isSubmitting;
  final bool isSubmitted;
  final LocationStatus locationStatus;
  final double? currentLat;
  final double? currentLng;
  final double? centerLat;
  final double? centerLng;
  final double? distanceFromCenter;

  NewSubmissionState copyWith({
    Task? task,
    bool? isLoading,
    TaskMetaData? metaData,
    List<ChecklistItem>? checklistTemplate,
    List<CapturedPhoto>? capturedPhotos,
    List<ImageChecklistEntry>? imageChecklistEntries,
    String? observations,
    String? error,
    bool? isSubmitting,
    bool? isSubmitted,
    LocationStatus? locationStatus,
    double? currentLat,
    double? currentLng,
    double? centerLat,
    double? centerLng,
    double? distanceFromCenter,
  }) {
    return NewSubmissionState(
      task: task ?? this.task,
      isLoading: isLoading ?? this.isLoading,
      metaData: metaData ?? this.metaData,
      checklistTemplate: checklistTemplate ?? this.checklistTemplate,
      capturedPhotos: capturedPhotos ?? this.capturedPhotos,
      imageChecklistEntries:
          imageChecklistEntries ?? this.imageChecklistEntries,
      observations: observations ?? this.observations,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
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

  static const double geofenceRadius = 500.0;

  bool get isInsideGeofence {
    if (distanceFromCenter == null) return false;
    return distanceFromCenter! <= geofenceRadius;
  }

  bool get isImageTask => TaskType.fromString(task?.taskType) == TaskType.image;
  bool get isChecklistTask =>
      TaskType.fromString(task?.taskType) == TaskType.checklist;

  int get requiredImageCount => 1;
  bool get hasReachedImageLimit => capturedPhotos.length >= requiredImageCount;

  bool get canSubmit {
    if (isImageTask) {
      return capturedPhotos.length >= requiredImageCount;
    } else if (isChecklistTask) {
      if (imageChecklistEntries.isEmpty) return false;
      return imageChecklistEntries.every((entry) {
        return entry.checklist
            .where((item) => item.required)
            .every((item) => item.value != 'NA');
      });
    }
    return true;
  }
}

class NewSubmissionViewModel extends Notifier<NewSubmissionState> {
  final _imagePicker = ImagePicker();
  int _imageSequence = 0;

  @override
  NewSubmissionState build() {
    return const NewSubmissionState();
  }

  String _generateFilename() {
    _imageSequence++;
    return FileUtils.generateTaskImageFilename(
      taskUuid: state.task?.id ?? 'unknown',
      sequence: _imageSequence,
    );
  }

  List<ChecklistItem> _createChecklistCopy() {
    return state.checklistTemplate.map((item) {
      return ChecklistItem(
        id: item.id,
        question: item.question,
        required: item.required,
        value: 'NA',
      );
    }).toList();
  }

  /// Load task info (no existing submissions)
  void loadTask(String taskUuid) {
    state = const NewSubmissionState(isLoading: true);
    _imageSequence = 0;

    final appState = ref.read(appStateProvider);
    final task = appState.tasks.where((t) => t.id == taskUuid).firstOrNull;

    if (task == null) {
      state = state.copyWith(isLoading: false, error: 'Task not found');
      return;
    }

    TaskMetaData? metaData;
    if (task.metaDataJson != null) {
      try {
        final metaDataMap = jsonDecode(task.metaDataJson!);
        metaData = TaskMetaData.fromJson(metaDataMap);
      } catch (e) {
        AppLogger.instance.e('Error parsing metaData: $e');
      }
    }

    List<ChecklistItem> checklistTemplate = [];
    if (task.checklistJson != null) {
      try {
        final List<dynamic> checklistList = jsonDecode(task.checklistJson!);
        checklistTemplate = checklistList
            .map((e) => ChecklistItem.fromJson(e))
            .toList();
      } catch (e) {
        AppLogger.instance.e('Error parsing checklist: $e');
      }
    }

    state = state.copyWith(
      task: task,
      isLoading: false,
      metaData: metaData,
      checklistTemplate: checklistTemplate,
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
          state = state.copyWith(locationStatus: LocationStatus.permissionDenied);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(locationStatus: LocationStatus.permissionDenied);
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

  void updateObservations(String text) {
    state = state.copyWith(observations: text);
  }

  // ==================== IMAGE TASK METHODS ====================

  Future<void> capturePhoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return;

      final filename = _generateFilename();
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/task_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final permanentPath = '${imagesDir.path}/$filename';
      await File(image.path).copy(permanentPath);

      imageCache.evict(permanentPath);
      state = state.copyWith(
        capturedPhotos: [
          ...state.capturedPhotos,
          CapturedPhoto(imagePath: permanentPath, filename: filename),
        ],
      );
    } catch (e) {
      AppLogger.instance.e('Error capturing photo: $e');
      state = state.copyWith(error: 'Failed to capture photo');
    }
  }

  void removePhoto(int index) {
    final updatedPhotos = List<CapturedPhoto>.from(state.capturedPhotos);
    updatedPhotos.removeAt(index);
    state = state.copyWith(capturedPhotos: updatedPhotos);
  }

  // ==================== CHECKLIST TASK METHODS ====================

  Future<void> capturePhotoWithChecklist(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return;

      final filename = _generateFilename();
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/task_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final permanentPath = '${imagesDir.path}/$filename';
      await File(image.path).copy(permanentPath);

      imageCache.evict(permanentPath);

      final newEntry = ImageChecklistEntry(
        filename: filename,
        localPath: permanentPath,
        checklist: _createChecklistCopy(),
      );

      state = state.copyWith(
        imageChecklistEntries: [...state.imageChecklistEntries, newEntry],
      );
    } catch (e) {
      AppLogger.instance.e('Error capturing photo: $e');
      state = state.copyWith(error: 'Failed to capture photo');
    }
  }

  void setImageChecklistAnswer(
    int imageIndex,
    int checklistIndex,
    String value,
  ) {
    if (imageIndex < 0 || imageIndex >= state.imageChecklistEntries.length) {
      return;
    }

    final entries = List<ImageChecklistEntry>.from(state.imageChecklistEntries);
    final entry = entries[imageIndex];
    final updatedChecklist = List<ChecklistItem>.from(entry.checklist);

    if (checklistIndex < 0 || checklistIndex >= updatedChecklist.length) return;

    updatedChecklist[checklistIndex] = updatedChecklist[checklistIndex]
        .copyWith(value: value);
    entries[imageIndex] = entry.copyWith(checklist: updatedChecklist);

    state = state.copyWith(imageChecklistEntries: entries);
  }

  void removeImageChecklistEntry(int index) {
    if (index < 0 || index >= state.imageChecklistEntries.length) return;

    final entries = List<ImageChecklistEntry>.from(state.imageChecklistEntries);
    entries.removeAt(index);
    state = state.copyWith(imageChecklistEntries: entries);
  }

  // ==================== SUBMISSION ====================

  Future<bool> submitNewSubmission() async {
    if (state.task == null) return false;

    state = state.copyWith(isSubmitting: true);

    try {
      final db = ref.read(appDatabaseProvider);
      final taskUuid = state.task!.id;

      String verificationAnswersJson;
      String imagePathsJson;

      if (state.isChecklistTask) {
        // Store imageChecklist in API format: [{filename, checklist: [{id, question, required, value}]}]
        if (state.imageChecklistEntries.isNotEmpty) {
          verificationAnswersJson = jsonEncode(
            state.imageChecklistEntries.map((entry) => {
              'filename': entry.filename,
              'checklist': entry.checklist.map((item) => item.toJson()).toList(),
            }).toList(),
          );
        } else {
          verificationAnswersJson = '[]';
        }
        imagePathsJson = jsonEncode(
          state.imageChecklistEntries.map((entry) => entry.localPath).toList(),
        );
      } else {
        verificationAnswersJson = '[]';
        imagePathsJson = jsonEncode(
          state.capturedPhotos.map((photo) => photo.imagePath).toList(),
        );
      }

      final newSubmissionId = const Uuid().v4();
      await db
          .into(db.taskSubmissions)
          .insert(
            TaskSubmissionsCompanion.insert(
              id: newSubmissionId,
              taskId: taskUuid,
              observations: Value(state.observations),
              verificationAnswers: verificationAnswersJson,
              imagePaths: imagePathsJson,
              status: Value(SyncStatus.unsynced.toDbValue),
              latitude: Value(state.currentLat),
              longitude: Value(state.currentLng),
            ),
          );

      // Update task status
      await (db.update(db.tasks)..where((t) => t.id.equals(taskUuid))).write(
        TasksCompanion(taskStatus: Value(TaskStatus.submitted.toDbValue)),
      );

      // Refresh app state
      await ref.read(appStateProvider.notifier).loadFromDatabase();

      state = state.copyWith(isSubmitting: false, isSubmitted: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final newSubmissionViewModelProvider =
    NotifierProvider.autoDispose<NewSubmissionViewModel, NewSubmissionState>(
      NewSubmissionViewModel.new,
    );
