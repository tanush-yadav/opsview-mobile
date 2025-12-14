import '../app_strings.dart';

class EnStrings implements AppStrings {
  // App
  @override
  String get appName => 'OpsView';

  // Common
  @override
  String get ok => 'OK';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get exit => 'Exit';
  @override
  String get next => 'Next';
  @override
  String get back => 'Back';
  @override
  String get skip => 'Skip';
  @override
  String get submit => 'Submit';
  @override
  String get retry => 'Retry';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get success => 'Success';
  @override
  String get warning => 'Warning';

  // Splash
  @override
  String get splashLoading => 'Initializing...';

  // Login
  @override
  String get loginTitle => 'Operator Login';
  @override
  String get examCode => 'Exam Code';
  @override
  String get username => 'Username';
  @override
  String get password => 'Password';
  @override
  String get login => 'Login';
  @override
  String get loginFailed => 'Login Failed';
  @override
  String get invalidCredentials => 'Invalid credentials. Please try again.';

  // Confirmation
  @override
  String get confirmationTitle => 'Confirm Details';
  @override
  String get examDetails => 'Exam Details';
  @override
  String get centerName => 'Center Name';
  @override
  String get examName => 'Exam Name';
  @override
  String get confirmAndProceed => 'Confirm & Proceed';
  @override
  String get exitApp => 'Exit App';

  // Profile
  @override
  String get profileCreation => 'Profile Creation';
  @override
  String get name => 'Name';
  @override
  String get mobileNumber => 'Mobile Number';
  @override
  String get aadhaar => 'Aadhaar Number';
  @override
  String get selfieCapture => 'Selfie Capture';
  @override
  String get captureSelfie => 'Capture Selfie';
  @override
  String get retake => 'Retake';
  @override
  String get otpVerification => 'OTP Verification';
  @override
  String get enterOtp => 'Enter OTP';
  @override
  String get resendOtp => 'Resend OTP';
  @override
  String get verifyOtp => 'Verify OTP';
  @override
  String get training => 'Training';
  @override
  String get watchTraining => 'Watch Training Video';
  @override
  String get skipTraining => 'Skip Training';

  // Shift Selection
  @override
  String get selectShift => 'Select Shift';
  @override
  String get mockDay => 'Mock Day';
  @override
  String get examDay => 'Exam Day';
  @override
  String get downloadingData => 'Downloading data...';

  // Home
  @override
  String get tasks => 'Tasks';
  @override
  String get pending => 'Pending';
  @override
  String get completed => 'Completed';
  @override
  String get synced => 'Synced';
  @override
  String get unsynced => 'Unsynced';
  @override
  String get syncWarning => 'Some data is not synced yet';
  @override
  String get capture => 'Capture';

  // Task Capture
  @override
  String get captureEvidence => 'Capture Evidence';
  @override
  String get addMessage => 'Add Message';
  @override
  String get messagePlaceholder => 'Enter optional message...';
  @override
  String get save => 'Save';
  @override
  String get previousCaptures => 'Previous Captures';

  // Settings
  @override
  String get settings => 'Settings';
  @override
  String get profile => 'Profile';
  @override
  String get syncNow => 'Sync Now';
  @override
  String get syncStatus => 'Sync Status';
  @override
  String get logout => 'Logout';
  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';
  @override
  String get unsyncedDataWarning => 'You have unsynced data. Logging out will delete this data.';

  // Errors
  @override
  String get networkError => 'Network error. Please check your connection.';
  @override
  String get serverError => 'Server error. Please try again later.';
  @override
  String get unknownError => 'An unknown error occurred.';
  @override
  String get locationPermissionDenied => 'Location permission denied.';
  @override
  String get cameraPermissionDenied => 'Camera permission denied.';
}
