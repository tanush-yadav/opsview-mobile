import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/providers/app_state_provider.dart';
import '../models/auth/center.dart' as model;
import '../models/auth/exam.dart' as model;
import '../models/auth/user.dart' as model;
import '../services/database/app_database.dart';
import '../services/sync/profile_sync_service.dart';
import '../services/sync/task_sync_service.dart';
import '../models/task/task_enums.dart';

class SettingsState {
  const SettingsState({
    this.user,
    this.exam,
    this.center,
    this.service,
    this.profile,
    this.isSyncing = false,
    this.hasPendingSync = false,
    this.isLoading = false,
  });

  final model.User? user;
  final model.Exam? exam;
  final model.Center? center;
  final String? service;
  final Profile? profile;
  final bool isSyncing;
  final bool hasPendingSync;
  final bool isLoading;

  SettingsState copyWith({
    model.User? user,
    model.Exam? exam,
    model.Center? center,
    String? service,
    Profile? profile,
    bool? isSyncing,
    bool? hasPendingSync,
    bool? isLoading,
  }) {
    return SettingsState(
      user: user ?? this.user,
      exam: exam ?? this.exam,
      center: center ?? this.center,
      service: service ?? this.service,
      profile: profile ?? this.profile,
      isSyncing: isSyncing ?? this.isSyncing,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String get userRole {
    if (user?.roles.isNotEmpty == true) {
      return user!.roles.first.description;
    }
    return 'Operator';
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final appState = ref.watch(appStateProvider);

    // Check for pending sync (tasks that are not submitted)
    final hasPendingSync = appState.tasks.any(
      (t) => t.taskStatus == TaskStatus.pending.toDbValue,
    );

    return SettingsState(
      user: appState.user,
      exam: appState.exam,
      center: appState.center,
      service: appState.user?.service,
      profile: appState.profile,
      hasPendingSync: hasPendingSync,
    );
  }

  Future<bool> syncData() async {
    state = state.copyWith(isSyncing: true);

    try {
      final profileSync = ref.read(profileSyncServiceProvider);
      final taskSync = ref.read(taskSyncServiceProvider);

      // Sync Profile
      await profileSync.syncAllProfiles();

      // Sync Tasks
      await taskSync.syncAllTasks();

      // Refresh App State to reflect changes (e.g. sync status)
      await ref.read(appStateProvider.notifier).loadFromDatabase();

      // Re-evaluate pending sync status
      final appState = ref.read(appStateProvider);
      final hasPendingSync = appState.tasks.any(
        (t) => t.taskStatus == TaskStatus.pending.toDbValue,
      );

      state = state.copyWith(isSyncing: false, hasPendingSync: hasPendingSync);
      return true;
    } catch (e) {
      state = state.copyWith(isSyncing: false);
      return false;
    }
  }

  Future<void> logout() async {
    final db = ref.read(appDatabaseProvider);
    const storage = FlutterSecureStorage();

    // Clear secure storage
    await storage.deleteAll();

    // Clear database
    await db.delete(db.sessions).go();
    await db.delete(db.profiles).go();
    await db.delete(db.tasks).go();
    await db.delete(db.taskSubmissions).go();

    // Clear app state
    ref.read(appStateProvider.notifier).clear();
  }

  Future<void> openTrainingVideo() async {
    final appState = ref.read(appStateProvider);
    final shiftId = appState.selectedShiftId;
    final shift = appState.exam?.shifts
        .where((s) => s.id == shiftId)
        .firstOrNull;

    if (shift != null && shift.services.isNotEmpty) {
      final trainingLink = shift.services.first.trainingLink;
      if (trainingLink.isNotEmpty) {
        final uri = Uri.parse(trainingLink);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);
