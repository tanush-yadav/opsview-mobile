import '../app_strings.dart';

class EnStrings implements AppStrings {
  // Login
  @override
  String get welcomeBack => 'Welcome Back';
  @override
  String get enterExamCredentials => 'Enter your exam credentials';
  @override
  String get examCode => 'EXAM CODE';
  @override
  String get examCodeHint => 'EX-8920';
  @override
  String get username => 'USERNAME';
  @override
  String get usernameHint => 'vikram.singh';
  @override
  String get password => 'PASSWORD';
  @override
  String get secureLogin => 'Login';
  @override
  String get loginFailed => 'Login failed';
  @override
  String get loginSuccess => 'Login successful';
  @override
  String get fillAllFields => 'Please fill in all fields';

  // Confirmation
  @override
  String get confirmationTitle => 'Confirm Details';
  @override
  String get verifyAssignment => 'Please verify your assignment';
  @override
  String get examCodeLabel => 'EXAM CODE';
  @override
  String get examNameLabel => 'EXAM NAME';
  @override
  String get centerCodeLabel => 'CENTER CODE';
  @override
  String get centerNameLabel => 'CENTER NAME';
  @override
  String get wrongCenter => 'Wrong Center';
  @override
  String get yesConfirm => 'Yes, Confirm';

  // Shift Selection
  @override
  String get selectShift => 'Select Shift';
  @override
  String get chooseAssignment => 'Choose your assignment for the day';
  @override
  String get examDay => 'Exam Day';
  @override
  String get mockDay => 'Mock Day';
  @override
  String get morningShift => 'Morning Shift';
  @override
  String get afternoonShift => 'Afternoon Shift';
  @override
  String get confirmShift => 'Confirm Shift';
  @override
  String get noShiftsAvailable => 'No shifts available';

  // Profile
  @override
  String get operatorProfile => 'Operator Profile';
  @override
  String get fillDetailsManually => 'Please fill your details manually';
  @override
  String get fullName => 'FULL NAME';
  @override
  String get age => 'AGE';
  @override
  String get mobileNumber => 'MOBILE NUMBER';
  @override
  String get aadhaarNumber => 'AADHAAR NUMBER';
  @override
  String get verify => 'Verify';
  @override
  String get continueToSelfie => 'Continue to Selfie';
  @override
  String get details => 'DETAILS';
  @override
  String get selfie => 'SELFIE';
  @override
  String get captureSelfie => 'Capture Selfie';
  @override
  String get selfieInstructions =>
      'Position your face in the frame and take a clear photo';
  @override
  String get retake => 'Retake';
  @override
  String get submit => 'Submit';

  // OTP
  @override
  String get enterOtpSentToMobile => 'Enter OTP sent to mobile';
  @override
  String get changeNumber => 'Change Number';
  @override
  String get submitOtp => 'Submit OTP';
  @override
  String get resendOtp => 'Resend OTP';
  @override
  String get verified => 'Verified';

  // Location & Selfie
  @override
  String get verifyLocationAndSelfie => 'Verify Location & Selfie';
  @override
  String get ensureInsideExamCentre => 'Ensure you are inside the exam centre';
  @override
  String get locationDetected => 'Location Detected';
  @override
  String get distanceFromCentre => 'DISTANCE FROM CENTRE';
  @override
  String get capturePhoto => 'Capture Photo';
  @override
  String get locationNotDetected => 'Location Not Detected';
  @override
  String get detectingLocation => 'Detecting location...';
  @override
  String get faceVerification => 'Face Verification';

  // Training
  @override
  String get trainingRequired => 'Training Required';
  @override
  String get completeBeforeShiftStart => 'Complete before shift start';
  @override
  String get duration => 'Duration';
  @override
  String get priority => 'Priority';
  @override
  String get mandatory => 'Mandatory';
  @override
  String get completed => 'Completed';
  @override
  String get skip => 'Skip';

  // Home
  @override
  String get notSubmitted => 'Not Submitted';
  @override
  String get submitted => 'Submitted';
  @override
  String get allTasksCompleted => 'All tasks completed';
  @override
  String get noSubmittedTasks => 'No submitted tasks';

  // Errors
  @override
  String get somethingWentWrong => 'Something went wrong';

  // Validation Errors
  @override
  String get invalidName => 'Please enter your full name';
  @override
  String get invalidAge => 'Enter a valid age';
  @override
  String get invalidMobile => 'Enter a valid 10-digit mobile number';
  @override
  String get invalidAadhaar => 'Enter a valid 12-digit Aadhaar number';

  // Settings
  @override
  String get profile => 'Profile';
  @override
  String get operatorAssignmentDetails => 'Operator Assignment Details';
  @override
  String get operatorIdentity => 'Operator Identity';
  @override
  String get currentAssignment => 'Current Assignment';
  @override
  String get assignedService => 'Assigned Service';
  @override
  String get training => 'Training';
  @override
  String get trainingModule => 'Training Module';
  @override
  String get viewBriefingVideo => 'View Briefing Video';
  @override
  String get onDuty => 'On Duty';
  @override
  String get syncRequired => 'Sync Required';
  @override
  String get syncBeforeLogout => 'Please sync your data before logging out';
  @override
  String get syncData => 'Sync Data';
  @override
  String get logout => 'Log Out';
  @override
  String get syncSuccess => 'Sync process completed';
  @override
  String get syncFailed => 'Sync failed. Please try again.';

  // Task Capture
  @override
  String get taskDetails => 'Task Details';
  @override
  String get instructions => 'INSTRUCTIONS';
  @override
  String get reportedIssues => 'REPORTED ISSUES';
  @override
  String get photoEvidence => 'PHOTO EVIDENCE';
  @override
  String get observations => 'OBSERVATIONS';
  @override
  String get observationsHint =>
      'Add any notes about the server room condition...';
  @override
  String get verificationChecklist => 'VERIFICATION CHECKLIST';
  @override
  String get takePhoto => 'Take Photo';
  @override
  String get addAnother => 'Add Another';
  @override
  String get tapToCaptureEvidence => 'Tap to capture evidence';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String completeTask(int count) => 'Complete Task ($count)';
  @override
  String get selectPhotoSource => 'Select Photo Source';
  @override
  String get camera => 'Camera';
  @override
  String get gallery => 'Gallery';
  @override
  String get cancel => 'Cancel';
}
