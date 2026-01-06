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
      final shifts = appState.exam!.shifts;

      final examShifts =
          shifts.where((s) => s.type == AppConstants.shiftTypeExamDay).toList();
      final mockShifts =
          shifts.where((s) => s.type == AppConstants.shiftTypeMockDay).toList();

      // Priority 1: Find active shift and show its tab
      final activeShift = _findActiveShift(shifts);
      if (activeShift != null) {
        final activeType = activeShift.type == AppConstants.shiftTypeExamDay
            ? ShiftType.exam
            : ShiftType.mock;
        return ShiftSelectionState(
          shifts: shifts,
          selectedType: activeType,
          isLoading: false,
        );
      }

      // Priority 2: Show non-empty tab (prefer exam, fallback to mock)
      ShiftType defaultType = ShiftType.exam;
      if (examShifts.isEmpty && mockShifts.isNotEmpty) {
        defaultType = ShiftType.mock;
      }
      // If both empty, defaults to exam (nothing to show anyway)

      return ShiftSelectionState(
        shifts: shifts,
        selectedType: defaultType,
        isLoading: false,
      );
    }

    return const ShiftSelectionState();
  }

  /// Finds a shift that is currently active based on date and time
  model.Shift? _findActiveShift(List<model.Shift> shifts) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final currentTime = DateFormat('HH:mm:ss').format(now);

    for (final shift in shifts) {
      // Check if today falls within shift date range
      if (shift.startDate.compareTo(today) <= 0 &&
          shift.endDate.compareTo(today) >= 0) {
        // Check if current time falls within shift time range
        if (shift.startTime.compareTo(currentTime) <= 0 &&
            shift.endTime.compareTo(currentTime) >= 0) {
          return shift;
        }
      }
    }
    return null;
  }

  /// Checks if a shift is in the future (hasn't started yet)
  bool isShiftFuture(model.Shift shift) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final currentTime = DateFormat('HH:mm:ss').format(now);

    // Future if start date is after today
    if (shift.startDate.compareTo(today) > 0) {
      return true;
    }
    // Future if same day but start time hasn't been reached
    if (shift.startDate.compareTo(today) == 0 &&
        shift.startTime.compareTo(currentTime) > 0) {
      return true;
    }
    return false;
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
