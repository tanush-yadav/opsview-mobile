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
  String get noShiftsAvailable;

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
  String get locationPermissionRequired;
  String get locationPermissionDeniedMessage;
  String get openSettings;
  String get retry;

  // Training
  String get trainingRequired;
  String get completeBeforeShiftStart;
  String get duration;
  String get priority;
  String get mandatory;
  String get completed;
  String get skip;

  // Home
  String get notSubmitted;
  String get submitted;
  String get allTasksCompleted;
  String get noSubmittedTasks;

  // Errors
  String get somethingWentWrong;

  // Validation Errors
  String get invalidName;
  String get invalidAge;
  String get invalidMobile;
  String get invalidAadhaar;

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
  String get profileNotCreated;
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
  String get submitTask;

  // Common
  String get insideZone;
  String get outsideZone;
  String get failedToLoadImage;
  String get passwordHint;
  String get verifyingSession;
  String get tapToView;
  String get score;
  String get liveness;
  String get requiredPhotoCaptured;
  String get addPhoto;
  String get addMorePhotos;
  String get captureEvidenceInstruction;
  String photoN(int n);
  String photosCount(int count);
  String get verification;
  String get photoVerification;
  String get newSubmission;
  String get addNewSubmission;
  String get addOptionalNotes;
  String get na;
  String get noSubmissionsYet;
  String get tapToAddFirstSubmission;
  String get notes;
  String get previousSubmission;
  String submissionsCount(int count);
}
