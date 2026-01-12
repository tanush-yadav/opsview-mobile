import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/providers/app_state_provider.dart';
import '../models/task/task_enums.dart';
import '../services/database/app_database.dart';

enum HomeTab { notSubmitted, submitted }

class HomeState {
  const HomeState({
    this.currentTab = HomeTab.notSubmitted,
    this.tasks = const [],
    this.isLoading = false,
    this.shiftName = '',
    this.shiftStartTime = '',
    this.shiftEndTime = '',
  });

  final HomeTab currentTab;
  final List<Task> tasks;
  final bool isLoading;
  final String shiftName;
  final String shiftStartTime;
  final String shiftEndTime;

  HomeState copyWith({
    HomeTab? currentTab,
    List<Task>? tasks,
    bool? isLoading,
    String? shiftName,
    String? shiftStartTime,
    String? shiftEndTime,
  }) {
    return HomeState(
      currentTab: currentTab ?? this.currentTab,
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      shiftName: shiftName ?? this.shiftName,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      shiftEndTime: shiftEndTime ?? this.shiftEndTime,
    );
  }

  List<Task> get notSubmittedTasks =>
      tasks.where((t) => t.taskStatus != 'SUBMITTED').toList();

  List<Task> get submittedTasks =>
      tasks.where((t) => t.taskStatus == 'SUBMITTED').toList();

  List<Task> get currentTasks =>
      currentTab == HomeTab.notSubmitted ? notSubmittedTasks : submittedTasks;
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    final appState = ref.watch(appStateProvider);
    final shiftId = appState.selectedShiftId;

    if (shiftId == null) {
      return const HomeState();
    }

    // Get tasks from app state (sorted by seqNumber)
    final tasks = List<Task>.from(appState.tasks)
      ..sort((a, b) => a.seqNumber.compareTo(b.seqNumber));

    // Get shift info from exam
    final exam = appState.exam;
    final shift = exam?.shifts.where((s) => s.id == shiftId).firstOrNull;

    return HomeState(
      tasks: tasks,
      shiftName: shift?.name ?? '',
      shiftStartTime: _formatTime(shift?.startTime ?? ''),
      shiftEndTime: _formatTime(shift?.endTime ?? ''),
    );
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '';
    // Convert 24h format (HH:mm) to 12h format
    try {
      final parts = time.split(':');
      if (parts.length < 2) return time;
      var hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (_) {
      return time;
    }
  }

  void switchTab(HomeTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  /// Get sync status for a task by its UUID
  /// Returns UNSYNCED if ANY submission for this task is unsynced
  SyncStatus getSyncStatus(String taskUuid) {
    final appState = ref.read(appStateProvider);

    // Find the task to get its CODE for backward compatibility
    final task = appState.tasks.where((t) => t.id == taskUuid).firstOrNull;
    final taskCode = task?.taskId;

    // Get all submissions for this task (by UUID or CODE)
    final submissions = appState.taskSubmissions
        .where(
          (s) =>
              s.taskId == taskUuid ||
              (taskCode != null && s.taskId == taskCode),
        )
        .toList();

    // If no submission exists, the task hasn't been submitted yet
    if (submissions.isEmpty) return SyncStatus.unsynced;

    // Check if ANY submission is unsynced
    final hasUnsynced = submissions.any(
      (s) => s.status == SyncStatus.unsynced.toDbValue,
    );

    return hasUnsynced ? SyncStatus.unsynced : SyncStatus.synced;
  }

  Future<void> callSupport() async {
    final appState = ref.read(appStateProvider);
    final contact = appState.center?.spoc2Contact;

    if (contact != null && contact.isNotEmpty) {
      final uri = Uri.parse('tel:$contact');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
