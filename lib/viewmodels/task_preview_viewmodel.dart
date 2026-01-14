import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_state_provider.dart';

import '../models/task/image_checklist_entry.dart';
import '../models/task/checklist_item.dart';
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

          if (checklistJson.isNotEmpty &&
              checklistJson.first is Map &&
              !checklistJson.first.containsKey('checklist')) {
            // Legacy format: List of ChecklistItems
            // We'll create one entry associated with the first image (or all images if we want to repeat)
            // For now, let's treat it as one checklist for the whole submission.
            // But our UI expects 1:1.
            // Best effort: Attach the full checklist to the first image.
            final legacyChecklist = checklistJson
                .map((e) => ChecklistItem.fromJson(e))
                .toList();
            
            for (int i = 0; i < imagePaths.length; i++) {
                // If we want to show the checklist for EVERY image implies duplication? 
                // Or just show it for the first one. 
                // Let's show it for the first one to avoid clutter, or maybe duplication is safer?
                // The user said "if someone submits two images, they definitely answered the checklist for both".
                // So replication seems appropriate for the "Mental Model", but technically it was one captured checklist.
                // Let's attach to first image.
                if (i == 0) {
                     checklistEntries.add(ImageChecklistEntry(
                        filename: 'legacy',
                        localPath: imagePaths[i],
                        checklist: legacyChecklist,
                     ));
                } else {
                     checklistEntries.add(ImageChecklistEntry(
                        filename: 'legacy_$i',
                        localPath: imagePaths[i],
                        checklist: [],
                     ));
                }
            }
          } else {
            // New format: [{filename, checklist: [{id, question, required, value}]}]
            for (int i = 0; i < checklistJson.length; i++) {
              final entry = checklistJson[i] as Map<String, dynamic>;
              final localPath = i < imagePaths.length ? imagePaths[i] : '';
              checklistEntries.add(
                ImageChecklistEntry.fromJson(entry, localPath),
              );
            }
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
