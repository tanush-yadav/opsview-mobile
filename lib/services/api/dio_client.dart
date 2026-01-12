import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import 'auth_interceptor.dart';
import 'device_info_interceptor.dart';
import 'error_interceptor.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(ref),
    DeviceInfoInterceptor(),
    LogInterceptor(requestBody: true, responseBody: true, error: true),
    ErrorInterceptor(),
  ]);

  return dio;
});
