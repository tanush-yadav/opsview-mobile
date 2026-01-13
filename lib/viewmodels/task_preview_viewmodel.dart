import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_state_provider.dart';

import '../models/task/image_checklist_entry.dart';
import '../models/task/task_meta_data.dart';
import '../services/database/app_database.dart';
import '../core/utils/app_logger.dart';
import '../models/task/task_enums.dart';

class TaskPreviewState {
  const TaskPreviewState({
    this.task,
    this.isLoading = true,
    this.metaData,
    this.submissions = const [],
    this.error,
  });

  final Task? task;
  final bool isLoading;
  final TaskMetaData? metaData;
  final List<SubmissionPreview> submissions;
  final String? error;

  TaskPreviewState copyWith({
    Task? task,
    bool? isLoading,
    TaskMetaData? metaData,
    List<SubmissionPreview>? submissions,
    String? error,
  }) {
    return TaskPreviewState(
      task: task ?? this.task,
      isLoading: isLoading ?? this.isLoading,
      metaData: metaData ?? this.metaData,
      submissions: submissions ?? this.submissions,
      error: error,
    );
  }

  bool get hasSubmissions => submissions.isNotEmpty;
  bool get isImageTask => TaskType.fromString(task?.taskType) == TaskType.image;
  bool get isChecklistTask =>
      TaskType.fromString(task?.taskType) == TaskType.checklist;
}

/// Preview data for a submission (read-only)
class SubmissionPreview {
  const SubmissionPreview({
    required this.id,
    required this.submittedAt,
    this.observations,
    this.imagePaths = const [],
    this.checklistEntries = const [],
  });

  final String id;
  final DateTime submittedAt;
  final String? observations;
  final List<String> imagePaths;
  final List<ImageChecklistEntry> checklistEntries;
}

class TaskPreviewViewModel extends Notifier<TaskPreviewState> {
  @override
  TaskPreviewState build() {
    return const TaskPreviewState();
  }

  /// Load task and its submissions (read-only)
  void loadTask(String taskUuid) {
    state = const TaskPreviewState(isLoading: true);

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

    // Get all submissions for this task
    var taskSubmissions = appState.taskSubmissions
        .where((s) => s.taskId == task.id)
        .toList();

    taskSubmissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    // For IMAGE tasks, only show the last submission
    if (TaskType.fromString(task.taskType) == TaskType.image &&
        taskSubmissions.isNotEmpty) {
      taskSubmissions = [taskSubmissions.first];
    }

    final submissions = <SubmissionPreview>[];

    for (final submission in taskSubmissions) {
      try {
        List<String> imagePaths = [];
        final List<ImageChecklistEntry> checklistEntries = [];

        // Parse image paths
        final List<dynamic> photosJson = jsonDecode(submission.imagePaths);
        imagePaths = photosJson.map((p) => p.toString()).toList();

        // Parse checklist if CHECKLIST task
        if (TaskType.fromString(task.taskType) == TaskType.checklist) {
          final List<dynamic> checklistJson = jsonDecode(
            submission.verificationAnswers,
          );
          // New format: [{filename, checklist: [{id, question, required, value}]}]
          for (int i = 0; i < checklistJson.length; i++) {
            final entry = checklistJson[i] as Map<String, dynamic>;
            final localPath = i < imagePaths.length ? imagePaths[i] : '';
            checklistEntries.add(
              ImageChecklistEntry.fromJson(entry, localPath),
            );
          }
        }

        submissions.add(
          SubmissionPreview(
            id: submission.id,
            submittedAt: submission.submittedAt,
            observations: submission.observations,
            imagePaths: imagePaths,
            checklistEntries: checklistEntries,
          ),
        );
      } catch (e) {
        AppLogger.instance.e('Error parsing submission ${submission.id}: $e');
      }
    }

    state = state.copyWith(
      task: task,
      isLoading: false,
      metaData: metaData,
      submissions: submissions,
    );
  }

  /// Reload after new submission
  void reload() {
    if (state.task != null) {
      loadTask(state.task!.id);
    }
  }
}

final taskPreviewViewModelProvider =
    NotifierProvider.autoDispose<TaskPreviewViewModel, TaskPreviewState>(
      TaskPreviewViewModel.new,
    );
