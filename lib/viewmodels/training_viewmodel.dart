import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_constants.dart';
import '../core/providers/app_state_provider.dart';
import '../models/auth/shift.dart' as model;
import '../services/database/app_database.dart';

class TrainingState {
  const TrainingState({
    this.selectedShift,
    this.currentService,
    this.isLoading = true,
  });
  final model.Shift? selectedShift;
  final model.ShiftService? currentService;
  final bool isLoading;

  TrainingState copyWith({
    model.Shift? selectedShift,
    model.ShiftService? currentService,
    bool? isLoading,
  }) {
    return TrainingState(
      selectedShift: selectedShift ?? this.selectedShift,
      currentService: currentService ?? this.currentService,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TrainingViewModel extends Notifier<TrainingState> {
  @override
  TrainingState build() {
    final appState = ref.watch(appStateProvider);

    if (appState.isLoaded && appState.exam != null) {
      final selectedShiftId = appState.selectedShiftId;
      final shifts = appState.exam!.shifts;
      final selectedShift = shifts.firstWhere(
        (s) => s.id == selectedShiftId,
        orElse: () => model.Shift(
          id: '',
          clientCode: '',
          examCode: '',
          name: '',
          type: '',
          startDate: '',
          startTime: '',
          endDate: '',
          endTime: '',
          services: [],
        ),
      );

      final currentService = selectedShift.services.isNotEmpty
          ? selectedShift.services.first
          : null;

      return TrainingState(
        selectedShift: selectedShift,
        currentService: currentService,
        isLoading: false,
      );
    }

    return const TrainingState();
  }

  Future<void> openTrainingVideo() async {
    final service = state.currentService;
    if (service == null || service.trainingLink.isEmpty) return;

    final uri = Uri.parse(service.trainingLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> completeTraining() async {
    final db = ref.read(appDatabaseProvider);
    final appState = ref.read(appStateProvider);
    final selectedShiftId = appState.selectedShiftId;

    // Mark training as completed on the profile for this shift
    if (selectedShiftId != null) {
      await (db.update(db.profiles)
            ..where((p) => p.shiftId.equals(selectedShiftId)))
          .write(const ProfilesCompanion(trainingCompleted: Value(true)));
    }

    // Update onboarding step to completed
    await (db.update(db.sessions)..where((t) => const Constant(true))).write(
      SessionsCompanion(onboardingStep: Value(OnboardingStep.completed.value)),
    );

    // Update app state
    ref
        .read(appStateProvider.notifier)
        .updateOnboardingStep(OnboardingStep.completed.value);
  }
}

final trainingViewModelProvider =
    NotifierProvider<TrainingViewModel, TrainingState>(TrainingViewModel.new);
