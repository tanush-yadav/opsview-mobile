import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/sync/profile_sync_service.dart';
import '../../services/sync/task_sync_service.dart';
import 'app_state_provider.dart';

/// Provides the current connectivity status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Manages auto-sync when connectivity changes
class ConnectivitySyncService {
  ConnectivitySyncService(this._ref);

  final Ref _ref;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;
  bool _isSyncing = false;

  /// Initialize connectivity listener for auto-sync
  void initialize() {
    _subscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);

    // Check initial connectivity
    Connectivity().checkConnectivity().then((results) {
      _wasOffline = !_isConnected(results);
      debugPrint('[ConnectivitySync] Initial state: ${_wasOffline ? "offline" : "online"}');
    });
  }

  /// Dispose the connectivity listener
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final isConnected = _isConnected(results);

    debugPrint('[ConnectivitySync] Connectivity changed: ${isConnected ? "online" : "offline"}');

    // If we just came online from being offline, trigger auto-sync
    if (isConnected && _wasOffline && !_isSyncing) {
      debugPrint('[ConnectivitySync] Came online - triggering auto-sync');
      await _performAutoSync();
    }

    _wasOffline = !isConnected;
  }

  Future<void> _performAutoSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final profileSync = _ref.read(profileSyncServiceProvider);
      final taskSync = _ref.read(taskSyncServiceProvider);

      // Sync profiles first
      final profilesSynced = await profileSync.syncAllProfiles();
      debugPrint('[ConnectivitySync] Profiles synced: $profilesSynced');

      // Then sync tasks
      final tasksSynced = await taskSync.syncAllTasks();
      debugPrint('[ConnectivitySync] Tasks synced: $tasksSynced');

      // Refresh app state to reflect sync status changes
      await _ref.read(appStateProvider.notifier).loadFromDatabase();

      debugPrint('[ConnectivitySync] Auto-sync complete');
    } catch (e) {
      debugPrint('[ConnectivitySync] Auto-sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }
}

/// Provider for the connectivity sync service
final connectivitySyncServiceProvider = Provider<ConnectivitySyncService>((ref) {
  final service = ConnectivitySyncService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
