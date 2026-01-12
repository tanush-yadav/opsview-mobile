import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../../models/api_response.dart';
import '../../models/task/operator_task.dart';
import 'dio_client.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(dioClientProvider));
});

class ApiService {
  ApiService(this._dio);
  final Dio _dio;

  // Auth
  Future<ApiResponse> login({
    required String examCode,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'examCode': examCode,
          'username': username.toLowerCase(),
          'password': password,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      final error = e.error;
      throw error is AppException
          ? error
          : AppException('Something went wrong');
    }
  }

  // Mobile Verification
  Future<ApiResponse> initiateMobileVerification(String contact) async {
    try {
      final response = await _dio.post(
        ApiConstants.mobileVerification,
        data: {'contact': contact},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      final error = e.error;
      throw error is AppException
          ? error
          : AppException('Something went wrong');
    }
  }

  Future<ApiResponse> verifyOtp(String verificationId, String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp(verificationId),
        data: {'otp': otp},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      final error = e.error;
      throw error is AppException
          ? error
          : AppException('Something went wrong');
    }
  }

  Future<ApiResponse> resendOtp(String verificationId) async {
    try {
      final response = await _dio.post(ApiConstants.resendOtp(verificationId));
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      final error = e.error;
      throw error is AppException
          ? error
          : AppException('Something went wrong');
    }
  }

  // Profile
  Future<ApiResponse> createProfile({
    required File selfieFile,
    required Map<String, dynamic> payload,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        selfieFile.path,
        filename: 'selfie.jpg',
      ),
      'payload': jsonEncode(payload),
    });

    final response = await _dio.post(
      ApiConstants.profiles,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return ApiResponse.fromJson(response.data);
  }

  // Exam & Tasks
  Future<ApiResponse> getExam(String examId) async {
    final response = await _dio.get(ApiConstants.exam(examId));
    return ApiResponse.fromJson(response.data);
  }

  Future<OperatorTasksResponse?> getOperatorTasks() async {
    final response = await _dio.get(ApiConstants.operatorTasks);
    final apiResponse = ApiResponse.fromJson(response.data);

    if (!apiResponse.isSuccess || apiResponse.data == null) return null;

    return OperatorTasksResponse.fromJson({'data': apiResponse.data});
  }

  Future<ApiResponse> updateTask({
    required String taskId,
    required List<File> files,
    required Map<String, dynamic> payload,
    Map<String, dynamic>? headers,
  }) async {
    final formData = FormData.fromMap({
      'files': await Future.wait(
        files.map((f) => MultipartFile.fromFile(f.path)),
      ),
      'payload': jsonEncode(payload),
    });

    final response = await _dio.patch(
      ApiConstants.updateTask(taskId),
      data: formData,
      options: Options(contentType: 'multipart/form-data', headers: headers),
    );
    return ApiResponse.fromJson(response.data);
  }

  // Signals
  Future<ApiResponse> sendSignal(List<Map<String, dynamic>> signals) async {
    final response = await _dio.post(ApiConstants.signals, data: signals);
    return ApiResponse.fromJson(response.data);
  }

  // Common
  Future<ApiResponse> getPlaceName(double lat, double lng) async {
    final response = await _dio.get(ApiConstants.placeName(lat, lng));
    return ApiResponse.fromJson(response.data);
  }
}
