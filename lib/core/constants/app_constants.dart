abstract class AppConstants {
  static const String appName = 'OpsView';
  static const String appVersion = '1.0.0';

  // Storage Keys (secure storage - sensitive data only)
  static const String accessTokenKey = 'access_token';

  // Image Settings
  static const int imageQuality = 70;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int targetImageSizeKB = 800; // ~500KB-1MB

  // Sync Settings
  static const int syncRetryAttempts = 3;
  static const int syncBatchSize = 5;

  // Shift Types
  static const String shiftTypeExamDay = 'ExamDay';
  static const String shiftTypeMockDay = 'MockDay';
}

/// Onboarding steps for user flow tracking
enum OnboardingStep {
  confirmation('confirmation'),
  shiftSelection('shiftSelection'),
  profile('profile'),
  training('training'),
  completed('completed');

  const OnboardingStep(this.value);

  final String value;

  static OnboardingStep fromString(String? value) {
    return OnboardingStep.values.firstWhere(
      (step) => step.value == value,
      orElse: () => OnboardingStep.confirmation,
    );
  }
}
