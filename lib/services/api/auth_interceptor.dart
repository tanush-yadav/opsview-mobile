import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_state_provider.dart';
import '../database/app_database.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login endpoint
    if (options.path.contains(ApiConstants.login)) {
      return handler.next(options);
    }

    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired - clear session and logout
      final db = _ref.read(appDatabaseProvider);
      await db.delete(db.sessions).go();
      await _storage.delete(key: AppConstants.accessTokenKey);
      _ref.read(appStateProvider.notifier).clear();
    }
    handler.next(err);
  }
}
