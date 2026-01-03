import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/auth/center.dart' as model;
import '../../models/auth/exam.dart' as model;
import '../../models/auth/user.dart' as model;
import '../../services/database/app_database.dart';

class AppState {
  const AppState({
    this.user,
    this.exam,
    this.center,
    this.profile,
    this.tasks = const [],
    this.taskSubmissions = const [],
    this.selectedShiftId,
    this.onboardingStep,
    this.isLoaded = false,
  });

  final model.User? user;
  final model.Exam? exam;
  final model.Center? center;
  final Profile? profile;
  final List<Task> tasks;
  final List<TaskSubmission> taskSubmissions;
  final String? selectedShiftId;
  final String? onboardingStep;
  final bool isLoaded;

  AppState copyWith({
    model.User? user,
    model.Exam? exam,
    model.Center? center,
    Profile? profile,
    List<Task>? tasks,
    List<TaskSubmission>? taskSubmissions,
    String? selectedShiftId,
    String? onboardingStep,
    bool? isLoaded,
  }) {
    return AppState(
      user: user ?? this.user,
      exam: exam ?? this.exam,
      center: center ?? this.center,
      profile: profile ?? this.profile,
      tasks: tasks ?? this.tasks,
      taskSubmissions: taskSubmissions ?? this.taskSubmissions,
      selectedShiftId: selectedShiftId ?? this.selectedShiftId,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  bool get isLoggedIn => user != null;

  double? get centerLat => double.tryParse(center?.lat ?? '');
  double? get centerLng => double.tryParse(center?.lng ?? '');
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return const AppState();
  }

  Future<void> loadFromDatabase() async {
    final db = ref.read(appDatabaseProvider);
    final sessions = await db.select(db.sessions).get();

    if (sessions.isNotEmpty) {
      final session = sessions.first;

      model.User? user;
      model.Exam? exam;
      model.Center? center;

      try {
        if (session.userJson != null) {
          user = model.User.fromJson(jsonDecode(session.userJson!));
        }
        if (session.examJson != null) {
          exam = model.Exam.fromJson(jsonDecode(session.examJson!));
        }
        if (session.centerJson != null) {
          center = model.Center.fromJson(jsonDecode(session.centerJson!));
        }
      } catch (_) {}

      // Load profile
      final profiles = await db.select(db.profiles).get();
      final profile = profiles.isNotEmpty ? profiles.first : null;

      // Load tasks for selected shift
      List<Task> tasks = [];
      if (session.selectedShiftId != null) {
        tasks = await (db.select(
          db.tasks,
        )..where((t) => t.shiftId.equals(session.selectedShiftId!))).get();
      }

      // Load task submissions
      final taskSubmissions = await db.select(db.taskSubmissions).get();

      state = AppState(
        user: user,
        exam: exam,
        center: center,
        profile: profile,
        tasks: tasks,
        taskSubmissions: taskSubmissions,
        selectedShiftId: session.selectedShiftId,
        onboardingStep: session.onboardingStep,
        isLoaded: true,
      );
    } else {
      state = state.copyWith(isLoaded: true);
    }
  }

  void updateOnboardingStep(String step) {
    state = state.copyWith(onboardingStep: step);
  }

  void updateSelectedShift(String shiftId) {
    state = state.copyWith(selectedShiftId: shiftId);
  }

  void updateProfile(Profile profile) {
    state = state.copyWith(profile: profile);
  }

  void updateTasks(List<Task> tasks) {
    state = state.copyWith(tasks: tasks);
  }

  void updateTaskSubmissions(List<TaskSubmission> submissions) {
    state = state.copyWith(taskSubmissions: submissions);
  }

  void clear() {
    state = const AppState(isLoaded: true);
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);
