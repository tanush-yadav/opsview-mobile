import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

import '../core/constants/app_constants.dart';
import '../core/providers/app_state_provider.dart';
import '../core/providers/connectivity_provider.dart';
import '../core/router/app_router.dart';

class SplashViewModel extends Notifier<void> {
  final _storage = const FlutterSecureStorage();

  @override
  void build() {}

  /// Returns the route to navigate to based on session state
  Future<String> getInitialRoute() async {
    debugPrint('[Splash] getInitialRoute: Starting...');
    try {
      // Request location permission upfront
      await _requestLocationPermission();

      final token = await _storage.read(key: AppConstants.accessTokenKey);
      debugPrint('[Splash] getInitialRoute: Token exists=${token != null && token.isNotEmpty}');

      if (token == null || token.isEmpty) {
        debugPrint('[Splash] getInitialRoute: No token, going to login');
        return AppRoutes.login;
      }

      // Load app state from database
      debugPrint('[Splash] getInitialRoute: Loading app state from database...');
      await ref.read(appStateProvider.notifier).loadFromDatabase();
      final appState = ref.read(appStateProvider);

      debugPrint('[Splash] getInitialRoute: App state loaded:');
      debugPrint('[Splash]   - isLoggedIn: ${appState.isLoggedIn}');
      debugPrint('[Splash]   - onboardingStep: ${appState.onboardingStep}');
      debugPrint('[Splash]   - selectedShiftId: ${appState.selectedShiftId}');
      debugPrint('[Splash]   - profiles count: ${appState.profiles.length}');
      debugPrint('[Splash]   - tasks count: ${appState.tasks.length}');

      // Initialize connectivity sync service for auto-sync when internet available
      ref.read(connectivitySyncServiceProvider).initialize();

      if (!appState.isLoggedIn) {
        debugPrint('[Splash] getInitialRoute: Not logged in, going to login');
        return AppRoutes.login;
      }

      final step = OnboardingStep.fromString(
        appState.onboardingStep ?? 'confirmation',
      );
      debugPrint('[Splash] getInitialRoute: Parsed step=$step');

      String route;
      switch (step) {
        case OnboardingStep.confirmation:
          route = AppRoutes.confirmation;
          break;
        case OnboardingStep.shiftSelection:
          route = AppRoutes.shiftSelection;
          break;
        case OnboardingStep.profile:
          route = AppRoutes.profile;
          break;
        case OnboardingStep.training:
          route = AppRoutes.training;
          break;
        case OnboardingStep.completed:
          route = AppRoutes.home;
          break;
      }
      debugPrint('[Splash] getInitialRoute: Navigating to $route');
      return route;
    } catch (e, stack) {
      debugPrint('[Splash] getInitialRoute: ERROR - $e');
      debugPrint('[Splash] getInitialRoute: Stack - $stack');
      return AppRoutes.login;
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (e) {
      // Silently ignore permission errors
    }
  }
}

final splashViewModelProvider = NotifierProvider<SplashViewModel, void>(
  SplashViewModel.new,
);
