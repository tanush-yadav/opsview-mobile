import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opsview/models/task/task_enums.dart';

import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../core/localization/app_strings.dart';
import '../core/providers/app_state_provider.dart';
import '../models/auth/login_response.dart';
import '../models/task/operator_task.dart';
import '../models/task/task_submission_response.dart';
import '../services/api/api_service.dart';
import '../services/database/app_database.dart';
import '../core/utils/app_logger.dart';

class LoginState {
  const LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  LoginState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
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
        await db
            .into(db.sessions)
            .insertOnConflictUpdate(
              SessionsCompanion.insert(
                id: loginResponse.user.id,
                service: Value(loginResponse.service),
                userJson: Value(jsonEncode(data['user'])),
                examJson: Value(jsonEncode(data['exam'])),
                centerJson: Value(jsonEncode(data['center'])),
              ),
            );

        // Load app state from database so it's available globally
        await ref.read(appStateProvider.notifier).loadFromDatabase();
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
      state = state.copyWith(isLoading: false, error: e.message);
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

  Future<void> _fetchAndStoreTasks(
    ApiService apiService,
    AppDatabase db,
  ) async {
    try {
      final operatorTasksResponse = await apiService.getOperatorTasks();

      if (operatorTasksResponse == null) return;

      for (final shiftWithTasks in operatorTasksResponse.data) {
        for (final task in shiftWithTasks.tasks) {
          await _storeTask(db, task);
        }
      }

      if (operatorTasksResponse.data.isNotEmpty) {
        await _sendTasksDownloadedSignal(apiService);
      }
    } catch (e, stackTrace) {
      AppLogger.instance.e('Error in _fetchAndStoreTasks: $e', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _storeTask(AppDatabase db, OperatorTask task) async {
    final hasSubmissions =
        task.submissions != null && task.submissions!.isNotEmpty;
    final taskStatus = hasSubmissions
        ? TaskStatus.submitted.toDbValue
        : TaskStatus.pending.toDbValue;

    await db
        .into(db.tasks)
        .insertOnConflictUpdate(
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
            taskStatus: Value(taskStatus),
            centerCode: task.centerCode,
            centerName: task.centerName,
            metaDataJson: Value(task.metaDataJson),
            checklistJson: Value(task.checklistJson),
          ),
        );

    if (hasSubmissions) {
      for (final submission in task.submissions!) {
        await _storeSubmission(db, task.id, submission);
      }
    }
  }

  Future<void> _storeSubmission(
    AppDatabase db,
    String taskId,
    TaskSubmissionResponse submission,
  ) async {
    final existing = await (db.select(
      db.taskSubmissions,
    )..where((t) => t.id.equals(submission.id))).getSingleOrNull();

    if (existing != null) return;

    await db
        .into(db.taskSubmissions)
        .insert(
          TaskSubmissionsCompanion.insert(
            id: submission.id,
            taskId: taskId,
            observations: Value(submission.message),
            verificationAnswers: submission.imageChecklist != null
                ? jsonEncode(submission.imageChecklist)
                : (submission.checklist != null
                    ? jsonEncode(submission.checklist)
                    : '[]'),
            imagePaths: submission.urls != null && submission.urls!.isNotEmpty
                ? jsonEncode(submission.urls!.map((e) => e.url).toList())
                : '[]',
            status: Value(SyncStatus.synced.toDbValue),
            latitude: Value(submission.lat),
            longitude: Value(submission.lng),
            syncedAt: Value(submission.syncedAt ?? DateTime.now()),
          ),
        );
  }

  Future<void> _sendTasksDownloadedSignal(ApiService apiService) async {
    try {
      final appState = ref.read(appStateProvider);
      await apiService.sendSignal([
        {
          'centerId': appState.center?.id,
          'clientTimestamp': DateTime.now().toUtc().toIso8601String(),
          'examId': appState.exam?.id,
          'type': 'TASKS_DOWNLOADED',
        },
      ]);
    } catch (e) {
      AppLogger.instance.e('Error sending signal: $e');
      // Don't rethrow as this is a non-blocking background operation
    }
  }
}

final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(
  LoginViewModel.new,
);
