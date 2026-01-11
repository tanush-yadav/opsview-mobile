import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  void i(dynamic message) {
    debugPrint('🔵 INFO: $message');
  }

  void d(dynamic message) {
    debugPrint('🟢 DEBUG: $message');
  }

  void w(dynamic message) {
    debugPrint('🟠 WARNING: $message');
  }

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('🔴 ERROR: $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
}
