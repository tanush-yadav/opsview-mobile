import 'package:dio/dio.dart';

import '../../core/exceptions/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _handleError(err);
    throw appException;
  }

  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException('Connection timeout. Please try again');
      case DioExceptionType.connectionError:
        return AppException('No internet connection');
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      case DioExceptionType.cancel:
        return AppException('Request cancelled');
      default:
        return AppException('Something went wrong. Please try again');
    }
  }

  AppException _handleResponseError(Response? response) {
    // Try to extract error message from response body
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final notify = data['notify'];
      if (notify is Map<String, dynamic> && notify['message'] != null) {
        return AppException(notify['message'] as String);
      }
      if (data['data'] is String) {
        return AppException(data['data'] as String);
      }
    }

    // Fallback to status code based messages
    switch (response?.statusCode) {
      case 400:
        return AppException('Bad request');
      case 401:
        return AppException('Invalid credentials');
      case 403:
        return AppException('Access denied');
      case 404:
        return AppException('Not found');
      case 500:
        return AppException('Server error. Please try again later');
      default:
        return AppException('Something went wrong. Please try again');
    }
  }
}
