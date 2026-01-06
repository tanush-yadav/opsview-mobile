import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_constants.dart';
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
  /// Also checks by CODE for backward compatibility with old submissions
  SyncStatus getSyncStatus(String taskUuid) {
    final appState = ref.read(appStateProvider);

    // Find the task to get its CODE for backward compatibility
    final task = appState.tasks.where((t) => t.id == taskUuid).firstOrNull;
    final taskCode = task?.taskId;

    // Try to find submission by UUID first (new format)
    var submission = appState.taskSubmissions
        .where((s) => s.taskId == taskUuid)
        .firstOrNull;

    // Fallback: try by CODE (old submissions before UUID fix)
    if (submission == null && taskCode != null) {
      submission = appState.taskSubmissions
          .where((s) => s.taskId == taskCode)
          .firstOrNull;
    }

    // If no submission exists, the task hasn't been submitted yet (pending)
    if (submission == null) return SyncStatus.unsynced;

    try {
      return SyncStatus.values.firstWhere(
        (e) => e.toDbValue == submission!.status,
        orElse: () => SyncStatus.unsynced,
      );
    } catch (_) {
      return SyncStatus.unsynced;
    }
  }

  Future<void> callSupport() async {
    final uri = Uri.parse('tel:${AppConstants.supportPhoneNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
