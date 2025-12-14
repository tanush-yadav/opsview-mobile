import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_locale.dart';
import 'strings/en_strings.dart';

final appStringsProvider = Provider<AppStrings>((ref) {
  final language = ref.watch(appLanguageProvider);
  return AppStrings.of(language);
});

abstract class AppStrings {
  // App
  String get appName;

  // Common
  String get ok;
  String get cancel;
  String get confirm;
  String get exit;
  String get next;
  String get back;
  String get skip;
  String get submit;
  String get retry;
  String get loading;
  String get error;
  String get success;
  String get warning;

  // Splash
  String get splashLoading;

  // Login
  String get loginTitle;
  String get examCode;
  String get username;
  String get password;
  String get login;
  String get loginFailed;
  String get invalidCredentials;

  // Confirmation
  String get confirmationTitle;
  String get examDetails;
  String get centerName;
  String get examName;
  String get confirmAndProceed;
  String get exitApp;

  // Profile
  String get profileCreation;
  String get name;
  String get mobileNumber;
  String get aadhaar;
  String get selfieCapture;
  String get captureSelfie;
  String get retake;
  String get otpVerification;
  String get enterOtp;
  String get resendOtp;
  String get verifyOtp;
  String get training;
  String get watchTraining;
  String get skipTraining;

  // Shift Selection
  String get selectShift;
  String get mockDay;
  String get examDay;
  String get downloadingData;

  // Home
  String get tasks;
  String get pending;
  String get completed;
  String get synced;
  String get unsynced;
  String get syncWarning;
  String get capture;

  // Task Capture
  String get captureEvidence;
  String get addMessage;
  String get messagePlaceholder;
  String get save;
  String get previousCaptures;

  // Settings
  String get settings;
  String get profile;
  String get syncNow;
  String get syncStatus;
  String get logout;
  String get logoutConfirmation;
  String get unsyncedDataWarning;

  // Errors
  String get networkError;
  String get serverError;
  String get unknownError;
  String get locationPermissionDenied;
  String get cameraPermissionDenied;

  factory AppStrings.of(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return EnStrings();
      // TODO: Add other languages here
      // case AppLanguage.hindi:
      //   return HiStrings();
    }
  }
}
