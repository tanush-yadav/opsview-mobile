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
import '../core/enums/location_status.dart';

class TaskCaptureState {
  const TaskCaptureState({
    this.task,
    this.isLoading = true,
    this.metaData,
    this.checklistTemplate = const [],
    this.capturedPhotos = const [],
    this.imageChecklistEntries = const [],
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
  
  /// Template checklist from task definition (used to create copies for each image)
  final List<ChecklistItem> checklistTemplate;
  
  /// Captured photos for IMAGE type tasks (no checklist)
  final List<CapturedPhoto> capturedPhotos;
  
  /// Image + checklist entries for CHECKLIST type tasks
  final List<ImageChecklistEntry> imageChecklistEntries;
  
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
    List<ChecklistItem>? checklistTemplate,
    List<CapturedPhoto>? capturedPhotos,
    List<ImageChecklistEntry>? imageChecklistEntries,
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
      checklistTemplate: checklistTemplate ?? this.checklistTemplate,
      capturedPhotos: capturedPhotos ?? this.capturedPhotos,
      imageChecklistEntries: imageChecklistEntries ?? this.imageChecklistEntries,
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

  /// Whether this is an IMAGE type task (show photo capture, no checklist)
  bool get isImageTask => task?.taskType == 'IMAGE';

  /// Whether this is a CHECKLIST type task (images + per-image checklist)
  bool get isChecklistTask => task?.taskType == 'CHECKLIST';

  /// Required number of images for IMAGE tasks (default: 1)
  /// TODO: Parse from task metaData when API provides noOfImages field
  int get requiredImageCount => 1;

  /// Whether the image limit has been reached (only for IMAGE tasks)
  bool get hasReachedImageLimit => capturedPhotos.length >= requiredImageCount;

  /// Whether all required fields are complete
  bool get canComplete {
    if (isImageTask) {
      // Must have exactly the required number of images
      return capturedPhotos.length >= requiredImageCount;
    } else if (isChecklistTask) {
      // Must have at least one image with all required checklist items answered
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

class TaskCaptureViewModel extends Notifier<TaskCaptureState> {
  final _imagePicker = ImagePicker();
  int _imageSequence = 0; // For generating unique filenames

  @override
  TaskCaptureState build() {
    return const TaskCaptureState();
  }

  /// Generate a unique filename for API: {taskUUID}_{timestamp}_{sequence}.jpg
  String _generateFilename() {
    final taskUuid = state.task?.id ?? 'unknown';
    // Use first 8 chars of UUID for brevity
    final shortUuid = taskUuid.length >= 8 ? taskUuid.substring(0, 8) : taskUuid;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _imageSequence++;
    return '${shortUuid}_${timestamp}_${_imageSequence.toString().padLeft(3, '0')}.jpg';
  }

  /// Create a fresh copy of the checklist template for a new image
  List<ChecklistItem> _createChecklistCopy() {
    return state.checklistTemplate.map((item) {
      return ChecklistItem(
        id: item.id,
        question: item.question,
        required: item.required,
        value: 'NA', // Reset to unanswered
      );
    }).toList();
  }

  /// Load task by its UUID (not the CODE)
  void loadTask(String taskUuid) {
    // CRITICAL: Reset state completely before loading new task
    state = const TaskCaptureState(isLoading: true);
    _imageSequence = 0;

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

    // Parse checklist template from JSON
    List<ChecklistItem> checklistTemplate = [];
    if (task.checklistJson != null) {
      try {
        final List<dynamic> checklistList = jsonDecode(task.checklistJson!);
        checklistTemplate = checklistList
            .map((e) => ChecklistItem.fromJson(e))
            .toList();
      } catch (e) {
        print('Error parsing checklist: $e');
      }
    }

    // Get submissions for this task
    // For IMAGE tasks: show last submission only
    // For CHECKLIST tasks: show all submissions
    var taskSubmissions = appState.taskSubmissions
        .where((s) => s.taskId == task.id)
        .toList();

    // Fallback: try by CODE for old submissions
    if (taskSubmissions.isEmpty) {
      taskSubmissions = appState.taskSubmissions
          .where((s) => s.taskId == task.taskId)
          .toList();
    }

    // Sort by submittedAt descending (newest first)
    taskSubmissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    String observations = '';
    List<CapturedPhoto> capturedPhotos = [];
    List<ImageChecklistEntry> imageChecklistEntries = [];
    String? submissionId;

    if (taskSubmissions.isNotEmpty) {
      if (task.taskType == 'CHECKLIST') {
        // CHECKLIST tasks: Load ALL submissions
        for (final submission in taskSubmissions) {
          try {
            final List<dynamic> entriesJson = jsonDecode(submission.verificationAnswers);
            
            for (var entryJson in entriesJson) {
              imageChecklistEntries.add(
                ImageChecklistEntry.fromJson(entryJson as Map<String, dynamic>),
              );
            }
          } catch (e) {
            print('Error parsing imageChecklistEntries: $e');
            // Fallback: try old format (just paths, no checklist data)
            try {
              final List<dynamic> pathsJson = jsonDecode(submission.imagePaths);
              for (var path in pathsJson) {
                imageChecklistEntries.add(ImageChecklistEntry(
                  filename: _generateFilename(),
                  localPath: path.toString(),
                  checklist: checklistTemplate.map((item) {
                    return ChecklistItem(
                      id: item.id,
                      question: item.question,
                      required: item.required,
                      value: 'NA',
                    );
                  }).toList(),
                ));
              }
            } catch (e2) {
              print('Error parsing old format: $e2');
            }
          }
        }
        // Use the most recent submission's ID and observations
        submissionId = taskSubmissions.first.id;
        observations = taskSubmissions.first.observations ?? '';
        print('Loaded ${imageChecklistEntries.length} entries from ${taskSubmissions.length} submissions');
      } else {
        // IMAGE tasks: Load LAST submission only
        final submission = taskSubmissions.first;
        submissionId = submission.id;
        observations = submission.observations ?? '';

        try {
          final List<dynamic> photosJson = jsonDecode(submission.imagePaths);
          int seq = 0;
          capturedPhotos = photosJson.map((p) {
            seq++;
            return CapturedPhoto(
              imagePath: p.toString(),
              filename: '${task.id.substring(0, 8)}_restored_${seq.toString().padLeft(3, '0')}.jpg',
            );
          }).toList();
        } catch (e) {
          print('Error parsing captured photos: $e');
        }
      }
    }

    state = state.copyWith(
      task: task,
      isLoading: false,
      metaData: metaData,
      checklistTemplate: checklistTemplate,
      observations: observations,
      capturedPhotos: capturedPhotos,
      imageChecklistEntries: imageChecklistEntries,
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

  void updateObservations(String text) {
    state = state.copyWith(observations: text);
  }

  // ==================== IMAGE TASK METHODS ====================

  /// Capture photo for IMAGE type tasks
  Future<void> capturePhoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return;

      // Generate unique filename and copy to permanent path
      final filename = _generateFilename();
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/task_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final permanentPath = '${imagesDir.path}/$filename';
      await File(image.path).copy(permanentPath);
      
      // Clear any cached version of this path
      imageCache.evict(permanentPath);
      
      addPhoto(CapturedPhoto(imagePath: permanentPath, filename: filename));
    } catch (e) {
      print('Error capturing photo: $e');
      state = state.copyWith(error: 'Failed to capture photo');
    }
  }

  void addPhoto(CapturedPhoto photo) {
    // Clear image cache for this path to avoid showing stale images
    imageCache.evict(photo.imagePath);
    state = state.copyWith(capturedPhotos: [...state.capturedPhotos, photo]);
  }

  void removePhoto(int index) {
    final updatedPhotos = List<CapturedPhoto>.from(state.capturedPhotos);
    updatedPhotos.removeAt(index);
    state = state.copyWith(capturedPhotos: updatedPhotos);
  }

  // ==================== CHECKLIST TASK METHODS ====================

  /// Capture photo and add new image+checklist entry for CHECKLIST type tasks
  Future<void> capturePhotoWithChecklist(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return;

      // Generate unique filename and copy to permanent path
      final filename = _generateFilename();
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/task_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final permanentPath = '${imagesDir.path}/$filename';
      await File(image.path).copy(permanentPath);
      
      // Clear any cached version of this path
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
      print('Error capturing photo: $e');
      state = state.copyWith(error: 'Failed to capture photo');
    }
  }

  /// Set checklist answer for a specific image entry
  void setImageChecklistAnswer(int imageIndex, int checklistIndex, String value) {
    if (imageIndex < 0 || imageIndex >= state.imageChecklistEntries.length) return;

    final entries = List<ImageChecklistEntry>.from(state.imageChecklistEntries);
    final entry = entries[imageIndex];
    final updatedChecklist = List<ChecklistItem>.from(entry.checklist);
    
    if (checklistIndex < 0 || checklistIndex >= updatedChecklist.length) return;
    
    updatedChecklist[checklistIndex] = updatedChecklist[checklistIndex].copyWith(value: value);
    entries[imageIndex] = entry.copyWith(checklist: updatedChecklist);
    
    state = state.copyWith(imageChecklistEntries: entries);
  }

  /// Remove an image+checklist entry
  void removeImageChecklistEntry(int index) {
    if (index < 0 || index >= state.imageChecklistEntries.length) return;
    
    final entries = List<ImageChecklistEntry>.from(state.imageChecklistEntries);
    entries.removeAt(index);
    state = state.copyWith(imageChecklistEntries: entries);
  }

  // ==================== SUBMISSION ====================

  Future<bool> completeTask() async {
    if (state.task == null) return false;

    try {
      final db = ref.read(appDatabaseProvider);
      final taskUuid = state.task!.id;

      String verificationAnswersJson;
      String imagePathsJson;

      if (state.isChecklistTask) {
        // Build imageChecklist format for CHECKLIST tasks
        verificationAnswersJson = jsonEncode(
          state.imageChecklistEntries.map((entry) => entry.toJson()).toList(),
        );
        imagePathsJson = jsonEncode(
          state.imageChecklistEntries.map((entry) => entry.localPath).toList(),
        );
      } else {
        // IMAGE tasks - just paths, no checklist
        verificationAnswersJson = '[]';
        imagePathsJson = jsonEncode(
          state.capturedPhotos.map((photo) => photo.imagePath).toList(),
        );
      }

      final latitude = state.currentLat;
      final longitude = state.currentLng;

      if (state.submissionId != null) {
        // Update existing record
        await (db.update(
          db.taskSubmissions,
        )..where((t) => t.id.equals(state.submissionId!))).write(
          TaskSubmissionsCompanion(
            observations: Value(state.observations),
            verificationAnswers: Value(verificationAnswersJson),
            imagePaths: Value(imagePathsJson),
            status: Value(SyncStatus.unsynced.toDbValue),
            submittedAt: Value(DateTime.now()),
            latitude: Value(latitude),
            longitude: Value(longitude),
          ),
        );
      } else {
        // Insert new record
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
                latitude: Value(latitude),
                longitude: Value(longitude),
              ),
            );
      }

      // Update task status to SUBMITTED
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
