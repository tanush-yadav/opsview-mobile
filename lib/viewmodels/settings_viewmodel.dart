import 'package:connectivity_plus/connectivity_plus.dart';
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

enum SyncResult {
  /// All data was already synced, nothing to do
  alreadySynced,
  /// Data synced successfully
  success,
  /// Some items synced, some failed
  partialSuccess,
  /// No internet connection
  noInternet,
  /// Sync failed due to an error
  error,
}

class SettingsState {
  const SettingsState({
    this.user,
    this.exam,
    this.center,
    this.service,
    this.profiles = const [],
    this.selectedShiftId,
    this.isSyncing = false,
    this.hasUnsyncedTasks = false,
    this.isLoading = false,
  });

  final model.User? user;
  final model.Exam? exam;
  final model.Center? center;
  final String? service;
  final List<Profile> profiles;
  final String? selectedShiftId;
  final bool isSyncing;
  final bool hasUnsyncedTasks; // Submissions not yet synced
  final bool isLoading;

  /// Get the profile for the current selected shift
  Profile? get profile {
    if (selectedShiftId == null) return null;
    return profiles.where((p) => p.shiftId == selectedShiftId).firstOrNull;
  }

  /// Can logout if no profile exists (nothing to sync) or all tasks are synced
  bool get canLogout => profile == null || (!hasUnsyncedTasks && !isSyncing);

  /// Show warning if either incomplete or unsynced
  bool get showLogoutWarning => hasUnsyncedTasks;

  SettingsState copyWith({
    model.User? user,
    model.Exam? exam,
    model.Center? center,
    String? service,
    List<Profile>? profiles,
    String? selectedShiftId,
    bool? isSyncing,
    bool? hasIncompleteTasks,
    bool? hasUnsyncedTasks,
    bool? isLoading,
  }) {
    return SettingsState(
      user: user ?? this.user,
      exam: exam ?? this.exam,
      center: center ?? this.center,
      service: service ?? this.service,
      profiles: profiles ?? this.profiles,
      selectedShiftId: selectedShiftId ?? this.selectedShiftId,
      isSyncing: isSyncing ?? this.isSyncing,
      hasUnsyncedTasks: hasUnsyncedTasks ?? this.hasUnsyncedTasks,
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

    // Check for unsynced submissions
    final hasUnsyncedTasks = appState.taskSubmissions.any(
      (s) => s.status == SyncStatus.unsynced.toDbValue,
    );

    return SettingsState(
      user: appState.user,
      exam: appState.exam,
      center: appState.center,
      service: appState.user?.service,
      profiles: appState.profiles,
      selectedShiftId: appState.selectedShiftId,
      hasUnsyncedTasks: hasUnsyncedTasks,
    );
  }

  Future<SyncResult> syncData() async {
    state = state.copyWith(isSyncing: true);

    try {
      // Check internet connectivity first
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet = connectivityResults.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);

      if (!hasInternet) {
        state = state.copyWith(isSyncing: false);
        return SyncResult.noInternet;
      }

      final profileSync = ref.read(profileSyncServiceProvider);
      final taskSync = ref.read(taskSyncServiceProvider);

      // Check if there's anything to sync
      final unsyncedProfiles = await profileSync.getUnsyncedProfiles();
      final unsyncedTasks = await taskSync.getUnsyncedTasks();
      final totalToSync = unsyncedProfiles.length + unsyncedTasks.length;

      if (totalToSync == 0) {
        state = state.copyWith(isSyncing: false);
        return SyncResult.alreadySynced;
      }

      // Sync Profile
      final profilesSynced = await profileSync.syncAllProfiles();

      // Sync Tasks
      final tasksSynced = await taskSync.syncAllTasks();

      final totalSynced = profilesSynced + tasksSynced;

      // Refresh App State to reflect changes (e.g. sync status)
      await ref.read(appStateProvider.notifier).loadFromDatabase();

      // Re-evaluate sync status by querying DB directly for accuracy
      await refreshSyncStatus();

      if (totalSynced == totalToSync) {
        return SyncResult.success;
      } else if (totalSynced > 0) {
        return SyncResult.partialSuccess;
      } else {
        return SyncResult.error;
      }
    } catch (e) {
      state = state.copyWith(isSyncing: false);
      return SyncResult.error;
    }
  }

  /// Refresh sync status by querying the database directly
  /// This ensures accurate sync status even if in-memory state is stale
  Future<void> refreshSyncStatus() async {
    final db = ref.read(appDatabaseProvider);
    final appState = ref.read(appStateProvider);

    // Get all tasks for current shift
    final allTasks = appState.tasks;
    final allTaskIds = allTasks.map((t) => t.id).toSet();

    // Get all submissions
    final allSubmissions = await db.select(db.taskSubmissions).get();
    final completedTaskIds = allSubmissions.map((s) => s.taskId).toSet();

    // Check for incomplete tasks
    final hasIncompleteTasks = allTaskIds
        .difference(completedTaskIds)
        .isNotEmpty;

    // Check for unsynced submissions
    final unsyncedSubmissions = allSubmissions.where(
      (s) => s.status == SyncStatus.unsynced.toDbValue,
    );
    final hasUnsyncedTasks = unsyncedSubmissions.isNotEmpty;

    state = state.copyWith(
      isSyncing: false,
      hasIncompleteTasks: hasIncompleteTasks,
      hasUnsyncedTasks: hasUnsyncedTasks,
    );
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
