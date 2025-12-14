abstract class AppConstants {
  static const String appName = 'OpsView';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String userDataKey = 'user_data';
  static const String sessionKey = 'session_data';

  // Image Settings
  static const int imageQuality = 70;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int targetImageSizeKB = 800; // ~500KB-1MB

  // Sync Settings
  static const int syncRetryAttempts = 3;
  static const int syncBatchSize = 5;
}
