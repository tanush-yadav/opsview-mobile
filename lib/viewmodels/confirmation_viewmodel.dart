import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/app_constants.dart';
import '../services/database/app_database.dart';

class ConfirmationViewModel extends Notifier<void> {
  final _storage = const FlutterSecureStorage();

  @override
  void build() {}

  Future<Session?> getSession() async {
    final db = ref.read(appDatabaseProvider);
    final sessions = await db.select(db.sessions).get();
    return sessions.isNotEmpty ? sessions.first : null;
  }

  Future<void> confirmCenter() async {
    final db = ref.read(appDatabaseProvider);
    await (db.update(db.sessions)
          ..where((t) => const Constant(true)))
        .write(
      SessionsCompanion(
        onboardingStep: Value(OnboardingStep.shiftSelection.value),
      ),
    );
  }

  Future<void> clearSession() async {
    // Clear session data from database
    final db = ref.read(appDatabaseProvider);
    await db.delete(db.sessions).go();

    // Clear token from secure storage
    await _storage.delete(key: AppConstants.accessTokenKey);
  }
}

final confirmationViewModelProvider =
    NotifierProvider<ConfirmationViewModel, void>(ConfirmationViewModel.new);
