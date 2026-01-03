import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_locale.dart';
import 'strings/en_strings.dart';

final appStringsProvider = Provider<AppStrings>((ref) {
  final language = ref.watch(appLanguageProvider);
  return AppStrings.of(language);
});

abstract class AppStrings {
  factory AppStrings.of(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return EnStrings();
    }
  }
  // Login
  String get welcomeBack;
  String get enterExamCredentials;
  String get examCode;
  String get examCodeHint;
  String get username;
  String get usernameHint;
  String get password;
  String get secureLogin;
  String get loginFailed;
  String get loginSuccess;
  String get fillAllFields;

  // Confirmation
  String get confirmationTitle;
  String get verifyAssignment;
  String get examCodeLabel;
  String get examNameLabel;
  String get centerCodeLabel;
  String get centerNameLabel;
  String get wrongCenter;
  String get yesConfirm;

  // Shift Selection
  String get selectShift;
  String get chooseAssignment;
  String get examDay;
  String get mockDay;
  String get morningShift;
  String get afternoonShift;
  String get confirmShift;

  // Profile
  String get operatorProfile;
  String get fillDetailsManually;
  String get fullName;
  String get age;
  String get mobileNumber;
  String get aadhaarNumber;
  String get verify;
  String get continueToSelfie;
  String get details;
  String get selfie;
  String get captureSelfie;
  String get selfieInstructions;
  String get retake;
  String get submit;

  // OTP
  String get enterOtpSentToMobile;
  String get changeNumber;
  String get submitOtp;
  String get resendOtp;
  String get verified;

  // Location & Selfie
  String get verifyLocationAndSelfie;
  String get ensureInsideExamCentre;
  String get locationDetected;
  String get distanceFromCentre;
  String get capturePhoto;
  String get locationNotDetected;
  String get detectingLocation;
  String get faceVerification;

  // Training
  String get trainingRequired;
  String get completeBeforeShiftStart;
  String get duration;
  String get priority;
  String get mandatory;
  String get completed;

  // Home
  String get notSubmitted;
  String get submitted;
  String get allTasksCompleted;
  String get noSubmittedTasks;

  // Errors
  String get somethingWentWrong;

  // Settings
  String get profile;
  String get operatorAssignmentDetails;
  String get operatorIdentity;
  String get currentAssignment;
  String get assignedService;
  String get training;
  String get trainingModule;
  String get viewBriefingVideo;
  String get onDuty;
  String get syncRequired;
  String get syncBeforeLogout;
  String get syncData;
  String get logout;
  String get syncSuccess;
  String get syncFailed;

  // Task Capture
  String get taskDetails;
  String get instructions;
  String get reportedIssues;
  String get photoEvidence;
  String get observations;
  String get observationsHint;
  String get verificationChecklist;
  String get takePhoto;
  String get addAnother;
  String get tapToCaptureEvidence;
  String get yes;
  String get no;
  String completeTask(int count);
  String get selectPhotoSource;
  String get camera;
  String get gallery;
  String get cancel;
}
