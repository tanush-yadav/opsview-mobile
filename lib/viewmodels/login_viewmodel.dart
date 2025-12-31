import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../core/localization/app_strings.dart';
import '../core/providers/app_state_provider.dart';
import '../models/auth/login_response.dart';
import '../models/task/operator_task.dart';
import '../services/api/api_service.dart';
import '../services/database/app_database.dart';

class LoginState {

  const LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LoginViewModel extends Notifier<LoginState> {
  final _storage = const FlutterSecureStorage();

  @override
  LoginState build() => const LoginState();

  Future<bool> login({
    required String examCode,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.login(
        examCode: examCode,
        username: username,
        password: password,
      );

      if (response.isSuccess && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Store token in secure storage (sensitive data)
        await _storage.write(
          key: AppConstants.accessTokenKey,
          value: loginResponse.accessToken,
        );

        // Store session data in database (structured data)
        final db = ref.read(appDatabaseProvider);
        final data = response.data as Map<String, dynamic>;
        await db.into(db.sessions).insertOnConflictUpdate(
              SessionsCompanion.insert(
                id: loginResponse.user.id,
                service: Value(loginResponse.service),
                userJson: Value(jsonEncode(data['user'])),
                examJson: Value(jsonEncode(data['exam'])),
                centerJson: Value(jsonEncode(data['center'])),
              ),
            );

        // Fetch and store operator tasks
        await _fetchAndStoreTasks(apiService, db);

        // Load app state from database so it's available globally
        await ref.read(appStateProvider.notifier).loadFromDatabase();

        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      } else {
        final strings = ref.read(appStringsProvider);
        state = state.copyWith(
          isLoading: false,
          error: response.notify?.message ?? strings.somethingWentWrong,
        );
        return false;
      }
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      final strings = ref.read(appStringsProvider);
      state = state.copyWith(
        isLoading: false,
        error: strings.somethingWentWrong,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> _fetchAndStoreTasks(ApiService apiService, AppDatabase db) async {
    try {
      final tasksResponse = await apiService.getOperatorTasks();

      if (tasksResponse.isSuccess && tasksResponse.data != null) {
        final operatorTasksResponse =
            OperatorTasksResponse.fromJson({'data': tasksResponse.data});

        // Store all tasks from all shifts
        for (final shiftWithTasks in operatorTasksResponse.data) {
          for (final task in shiftWithTasks.tasks) {
            await db.into(db.tasks).insertOnConflictUpdate(
                  TasksCompanion.insert(
                    id: task.id,
                    clientCode: task.clientCode,
                    examId: task.examId,
                    centerId: task.centerId,
                    shiftId: task.shiftId,
                    service: task.service,
                    seqNumber: Value(task.seqNumber),
                    required: Value(task.required),
                    taskId: task.taskId,
                    taskLabel: task.taskLabel,
                    taskDesc: Value(task.taskDesc),
                    taskType: Value(task.taskType),
                    taskStatus: Value(task.taskStatus),
                    centerCode: task.centerCode,
                    centerName: task.centerName,
                  ),
                );
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);
