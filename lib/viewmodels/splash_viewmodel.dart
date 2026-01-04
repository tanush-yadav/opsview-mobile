import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/app_constants.dart';
import '../core/providers/app_state_provider.dart';
import '../core/router/app_router.dart';

class SplashViewModel extends Notifier<void> {
  final _storage = const FlutterSecureStorage();

  @override
  void build() {}

  /// Returns the route to navigate to based on session state
  Future<String> getInitialRoute() async {
    try {
      final token = await _storage.read(key: AppConstants.accessTokenKey);

      if (token == null || token.isEmpty) {
        return AppRoutes.login;
      }

      // Load app state from database
      await ref.read(appStateProvider.notifier).loadFromDatabase();
      final appState = ref.read(appStateProvider);

      if (!appState.isLoggedIn) {
        return AppRoutes.login;
      }

      final step = OnboardingStep.fromString(appState.onboardingStep ?? 'confirmation');

      switch (step) {
        case OnboardingStep.confirmation:
          return AppRoutes.confirmation;
        case OnboardingStep.shiftSelection:
          return AppRoutes.shiftSelection;
        case OnboardingStep.profile:
          return AppRoutes.profile;
        case OnboardingStep.training:
          return AppRoutes.training;
        case OnboardingStep.completed:
          return AppRoutes.home;
      }
    } catch (e) {
      return AppRoutes.login;
    }
  }
}

final splashViewModelProvider =
    NotifierProvider<SplashViewModel, void>(SplashViewModel.new);
