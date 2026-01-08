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
    this.profiles = const [],
    this.tasks = const [],
    this.taskSubmissions = const [],
    this.selectedShiftId,
    this.onboardingStep,
    this.isLoaded = false,
  });

  final model.User? user;
  final model.Exam? exam;
  final model.Center? center;
  final List<Profile> profiles;
  final List<Task> tasks;
  final List<TaskSubmission> taskSubmissions;
  final String? selectedShiftId;
  final String? onboardingStep;
  final bool isLoaded;

  AppState copyWith({
    model.User? user,
    model.Exam? exam,
    model.Center? center,
    List<Profile>? profiles,
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
      profiles: profiles ?? this.profiles,
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
    print('loadFromDatabase: Starting...');
    final db = ref.read(appDatabaseProvider);
    final sessions = await db.select(db.sessions).get();
    print('loadFromDatabase: Got ${sessions.length} sessions');

    if (sessions.isNotEmpty) {
      final session = sessions.first;

      model.User? user;
      model.Exam? exam;
      model.Center? center;

      try {
        if (session.userJson != null) {
          print('loadFromDatabase: Parsing user...');
          user = model.User.fromJson(jsonDecode(session.userJson!));
        }
        if (session.examJson != null) {
          print('loadFromDatabase: Parsing exam...');
          exam = model.Exam.fromJson(jsonDecode(session.examJson!));
        }
        if (session.centerJson != null) {
          print('loadFromDatabase: Parsing center...');
          center = model.Center.fromJson(jsonDecode(session.centerJson!));
        }
      } catch (e) {
        print('loadFromDatabase: Error parsing session data: $e');
      }

      // Load profile
      print('loadFromDatabase: Loading profiles...');
      List<Profile> profiles = [];
      try {
        profiles = await db.select(db.profiles).get();
        print('loadFromDatabase: Got ${profiles.length} profiles');
      } catch (e, stackTrace) {
        print('loadFromDatabase: ERROR loading profiles: $e');
        print('Stack trace: $stackTrace');
      }

      // Load tasks for selected shift
      print('loadFromDatabase: Loading tasks for shift ${session.selectedShiftId}...');
      List<Task> tasks = [];
      if (session.selectedShiftId != null) {
        tasks = await (db.select(
          db.tasks,
        )..where((t) => t.shiftId.equals(session.selectedShiftId!))).get();
      }
      print('loadFromDatabase: Got ${tasks.length} tasks');

      // Load task submissions
      print('loadFromDatabase: Loading task submissions...');
      final taskSubmissions = await db.select(db.taskSubmissions).get();
      print('loadFromDatabase: Got ${taskSubmissions.length} submissions');

      state = AppState(
        user: user,
        exam: exam,
        center: center,
        profiles: profiles,
        tasks: tasks,
        taskSubmissions: taskSubmissions,
        selectedShiftId: session.selectedShiftId,
        onboardingStep: session.onboardingStep,
        isLoaded: true,
      );
      print('loadFromDatabase: State updated');
    } else {
      state = state.copyWith(isLoaded: true);
      print('loadFromDatabase: No sessions, setting isLoaded');
    }
  }

  void updateOnboardingStep(String step) {
    state = state.copyWith(onboardingStep: step);
  }

  void updateSelectedShift(String shiftId) {
    state = state.copyWith(selectedShiftId: shiftId);
  }

  void updateProfile(List<Profile> profiles) {
    state = state.copyWith(profiles: profiles);
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
