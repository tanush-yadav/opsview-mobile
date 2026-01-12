abstract class ApiConstants {
  static const String baseUrl = 'https://dev-opsview.avyxon.com/api';

  // Auth
  static const String login = '/auth/op-login';

  // Mobile Verification
  static const String mobileVerification = '/mobile-verifications';
  static String verifyOtp(String id) => '/mobile-verifications/$id/verify';
  static String resendOtp(String id) => '/mobile-verifications/$id/resend';

  // Profile
  static const String profiles = '/profiles';

  // Exam & Tasks
  static String exam(String id) => '/exams/$id';
  static const String operatorTasks = '/tasks/operator-tasks';
  static String updateTask(String id) => '/tasks/$id/update-task';

  // Signals
  static const String signals = '/signals';

  // Common
  static String placeName(double lat, double lng) =>
      '/common/place-name?lat=$lat&lng=$lng';
}
