import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../core/providers/app_state_provider.dart';
import '../models/task/captured_photo.dart';
import '../models/task/reported_issue.dart';
import '../models/task/task_enums.dart';
import '../models/task/task_instruction.dart';
import '../models/task/verification_item.dart';
import '../services/database/app_database.dart';
import '../core/enums/location_status.dart';

class TaskCaptureState {
  const TaskCaptureState({
    this.task,
    this.isLoading = true,
    this.instructions = const [],
    this.reportedIssues = const [],
    this.verificationChecklist = const [],
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
  final List<TaskInstruction> instructions;
  final List<ReportedIssue> reportedIssues;
  final List<VerificationItem> verificationChecklist;
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
    List<TaskInstruction>? instructions,
    List<ReportedIssue>? reportedIssues,
    List<VerificationItem>? verificationChecklist,
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
      instructions: instructions ?? this.instructions,
      reportedIssues: reportedIssues ?? this.reportedIssues,
      verificationChecklist:
          verificationChecklist ?? this.verificationChecklist,
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

  int get answeredCount =>
      verificationChecklist.where((item) => item.answer != null).length;

  bool get canComplete =>
      verificationChecklist.isNotEmpty &&
      verificationChecklist.every((item) => item.answer != null);
}

class TaskCaptureViewModel extends Notifier<TaskCaptureState> {
  final _imagePicker = ImagePicker();

  @override
  TaskCaptureState build() {
    return const TaskCaptureState();
  }

  void loadTask(String taskId) {
    final appState = ref.read(appStateProvider);

    // Find task from app state
    print(taskId);
    final task = appState.tasks.where((t) => t.taskId == taskId).firstOrNull;
    print(task?.taskDesc);

    if (task == null) {
      state = state.copyWith(isLoading: false, error: 'Task not found');
      return;
    }

    // TODO: In the future, load instructions, issues, and verification from API/DB
    // For now, using mock data based on task type
    final instructions = _getMockInstructions(task);
    final reportedIssues = _getMockReportedIssues(task);
    var verificationChecklist = _getMockVerificationChecklist(task);

    // Check for existing submission
    final submission = appState.taskSubmissions
        .where((s) => s.taskId == taskId)
        .firstOrNull;

    String observations = '';
    List<CapturedPhoto> capturedPhotos = [];
    String? submissionId;

    if (submission != null) {
      submissionId = submission.id;
      observations = submission.observations ?? '';

      // Load verification answers
      try {
        final List<dynamic> answersJson = jsonDecode(
          submission.verificationAnswers,
        );
        verificationChecklist = verificationChecklist.map((item) {
          final answerData = answersJson.firstWhere(
            (a) => a['step'] == item.step,
            orElse: () => null,
          );
          if (answerData != null) {
            return item.copyWith(answer: answerData['answer']);
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
      instructions: instructions,
      reportedIssues: reportedIssues,
      verificationChecklist: verificationChecklist,
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
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(locationStatus: LocationStatus.error);
        return;
      }

      // Check and request permission
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

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Calculate distance from center
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

  List<TaskInstruction> _getMockInstructions(Task task) {
    // Mock instructions - replace with actual data from API when available
    return [
      const TaskInstruction(
        step: 1,
        text:
            "Verify the cooling unit's temperature reading is within normal range (18°C - 22°C).",
      ),
      const TaskInstruction(
        step: 2,
        text:
            "Inspect for any visible leaks or condensation around the base units.",
      ),
      const TaskInstruction(
        step: 3,
        text:
            "Ensure all server rack doors are securely locked after inspection.",
      ),
    ];
  }

  List<ReportedIssue> _getMockReportedIssues(Task task) {
    // Mock reported issues - replace with actual data from API when available
    return [
      const ReportedIssue(
        title: "Check cooling unit 3",
        description:
            "Reported noise issues from previous shift. Please verify if it's still persisting.",
        priority: "HIGH PRIORITY",
        reportedTime: "TODAY, 09:15 AM",
      ),
    ];
  }

  List<VerificationItem> _getMockVerificationChecklist(Task task) {
    // Mock verification checklist - replace with actual data from API when available
    return [
      VerificationItem(
        step: 1,
        question:
            "Is the cooling unit operating within normal temperature range?",
      ),
      VerificationItem(
        step: 2,
        question: "Are all server rack doors properly locked?",
      ),
      VerificationItem(
        step: 3,
        question: "Did you observe any unusual noise from equipment?",
      ),
    ];
  }

  void setVerificationAnswer(int index, bool? answer) {
    final updatedList = List<VerificationItem>.from(
      state.verificationChecklist,
    );
    updatedList[index] = updatedList[index].copyWith(answer: answer);
    state = state.copyWith(verificationChecklist: updatedList);
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

      // Add photo to state
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
      final taskId = state.task!.taskId;

      // Serialize verification answers to JSON
      final verificationAnswersJson = jsonEncode(
        state.verificationChecklist
            .map(
              (item) => {
                'step': item.step,
                'question': item.question,
                'answer': item.answer,
              },
            )
            .toList(),
      );

      // Serialize image paths to JSON (List<String>)
      final imagePathsJson = jsonEncode(
        state.capturedPhotos.map((photo) => photo.imagePath).toList(),
      );

      // Get current location from state
      final latitude = state.currentLat;
      final longitude = state.currentLng;

      // Create or update submission record
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
            submittedAt: Value(DateTime.now()), // Update submitted time
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
                taskId: taskId,
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
      await (db.update(db.tasks)..where((t) => t.taskId.equals(taskId))).write(
        TasksCompanion(taskStatus: Value(TaskStatus.submitted.toDbValue)),
      );

      // Refresh app state to reflect changes
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
