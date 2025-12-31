import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../core/providers/app_state_provider.dart';
import '../models/auth/shift.dart' as model;
import '../services/database/app_database.dart';

enum ShiftType { exam, mock }

class ShiftSelectionState {

  const ShiftSelectionState({
    this.shifts = const [],
    this.selectedType = ShiftType.exam,
    this.selectedShift,
    this.isLoading = true,
  });
  final List<model.Shift> shifts;
  final ShiftType selectedType;
  final model.Shift? selectedShift;
  final bool isLoading;

  ShiftSelectionState copyWith({
    List<model.Shift>? shifts,
    ShiftType? selectedType,
    model.Shift? selectedShift,
    bool? isLoading,
  }) {
    return ShiftSelectionState(
      shifts: shifts ?? this.shifts,
      selectedType: selectedType ?? this.selectedType,
      selectedShift: selectedShift ?? this.selectedShift,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<model.Shift> get filteredShifts {
    final typeString = selectedType == ShiftType.exam
        ? AppConstants.shiftTypeExamDay
        : AppConstants.shiftTypeMockDay;
    return shifts.where((s) => s.type == typeString).toList();
  }

  List<model.Shift> get _sortedShifts {
    final sorted = List<model.Shift>.from(filteredShifts);
    sorted.sort((a, b) {
      final dateCompare = a.startDate.compareTo(b.startDate);
      if (dateCompare != 0) return dateCompare;
      return a.startTime.compareTo(b.startTime);
    });
    return sorted;
  }

  Map<String, List<model.Shift>> get groupedShifts {
    final Map<String, List<model.Shift>> grouped = {};

    for (final shift in _sortedShifts) {
      final dateKey = _formatDateHeader(shift.startDate);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(shift);
    }

    return grouped;
  }

  String _formatDateHeader(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('EEE, MMM d');
      return formatter.format(date).toUpperCase();
    } catch (e) {
      return dateString.toUpperCase();
    }
  }
}

class ShiftSelectionViewModel extends Notifier<ShiftSelectionState> {
  @override
  ShiftSelectionState build() {
    // Watch appStateProvider - this will rebuild when appState changes
    final appState = ref.watch(appStateProvider);

    if (appState.isLoaded && appState.exam != null) {
      return ShiftSelectionState(
        shifts: appState.exam!.shifts,
        isLoading: false,
      );
    }

    return const ShiftSelectionState();
  }

  void selectType(ShiftType type) {
    state = state.copyWith(selectedType: type, selectedShift: null);
  }

  void selectShift(model.Shift shift) {
    state = state.copyWith(selectedShift: shift);
  }

  Future<void> confirmShift() async {
    if (state.selectedShift == null) return;

    final db = ref.read(appDatabaseProvider);
    await (db.update(db.sessions)..where((t) => const Constant(true))).write(
      SessionsCompanion(
        onboardingStep: Value(OnboardingStep.profile.value),
        selectedShiftId: Value(state.selectedShift!.id),
      ),
    );
  }
}

final shiftSelectionViewModelProvider =
    NotifierProvider<ShiftSelectionViewModel, ShiftSelectionState>(
        ShiftSelectionViewModel.new);
