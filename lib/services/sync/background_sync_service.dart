import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_state_provider.dart';
import '../../core/utils/app_logger.dart';
import 'profile_sync_service.dart';
import 'task_sync_service.dart';

final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  return BackgroundSyncService(
    ref,
    ref.watch(profileSyncServiceProvider),
    ref.watch(taskSyncServiceProvider),
  );
});

class BackgroundSyncService with WidgetsBindingObserver {
  BackgroundSyncService(this._ref, this._profileSync, this._taskSync);

  final Ref _ref;
  final ProfileSyncService _profileSync;
  final TaskSyncService _taskSync;

  Timer? _timer;
  bool _isSyncing = false;

  /// Start the periodic sync process
  void start() {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

    AppLogger.instance.i('BackgroundSyncService: Started/Resumed');

    // Run immediately on start/resume
    _attemptSync();

    // Schedule every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _attemptSync();
    });
  }

  /// Stop the background sync
  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    AppLogger.instance.i('BackgroundSyncService: Stopped/Paused');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is actionable again - Sync immediately!
        _startTimer();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // App is backgrounded - Pause timer correctly
        _stopTimer();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _attemptSync() async {
    // Prevent overlapping syncs
    if (_isSyncing) return;

    try {
      _isSyncing = true;

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // No internet, skip
        return;
      }

      // Check if there is anything to sync to avoid unnecessary work/logs

      AppLogger.instance.d(
        'BackgroundSyncService: checking for data to sync...',
      );

      bool didSync = false;

      // 1. Sync Profiles
      if (await _profileSync.hasUnsyncedProfiles()) {
        final count = await _profileSync.syncAllProfiles();
        if (count > 0) didSync = true;
      }

      // 2. Sync Tasks
      final unsyncedTasks = await _taskSync.getUnsyncedTasks();
      if (unsyncedTasks.isNotEmpty) {
        final count = await _taskSync.syncAllTasks();
        if (count > 0) didSync = true;
      }

      // 3. If data was synced, refresh the UI/App State
      if (didSync) {
        AppLogger.instance.i(
          'BackgroundSyncService: Synced data successfully. Refreshing UI.',
        );
        await _ref.read(appStateProvider.notifier).loadFromDatabase();
      }
    } catch (e) {
      AppLogger.instance.e('BackgroundSyncService: Error during sync', e);
    } finally {
      _isSyncing = false;
    }
  }
}
