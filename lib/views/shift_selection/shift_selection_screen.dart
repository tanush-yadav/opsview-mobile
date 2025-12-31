import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/localization/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../models/auth/shift.dart' as model;
import '../../viewmodels/shift_selection_viewmodel.dart';

class ShiftSelectionScreen extends ConsumerWidget {
  const ShiftSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final state = ref.watch(shiftSelectionViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Title
              Text(strings.selectShift, style: AppTextStyles.h1),
              const SizedBox(height: 8),
              // Subtitle
              Text(strings.chooseAssignment, style: AppTextStyles.muted),
              const SizedBox(height: 24),
              // Toggle buttons
              _buildToggleButtons(context, ref, strings, state),
              const SizedBox(height: 24),
              // Scrollable shifts list
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: state.groupedShifts.entries.map((entry) {
                      return _buildDateGroup(
                        context,
                        ref,
                        entry.key,
                        entry.value,
                        state.selectedShift,
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Confirm button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: PrimaryButton(
                  onPressed: state.selectedShift != null
                      ? () => _handleConfirm(context, ref, strings)
                      : null,
                  child: Text(
                    strings.confirmShift,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ShiftSelectionState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: strings.examDay,
              isSelected: state.selectedType == ShiftType.exam,
              onTap: () => ref
                  .read(shiftSelectionViewModelProvider.notifier)
                  .selectType(ShiftType.exam),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: strings.mockDay,
              isSelected: state.selectedType == ShiftType.mock,
              onTap: () => ref
                  .read(shiftSelectionViewModelProvider.notifier)
                  .selectType(ShiftType.mock),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateGroup(
    BuildContext context,
    WidgetRef ref,
    String date,
    List<model.Shift> shifts,
    model.Shift? selectedShift,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              date,
              style: AppTextStyles.labelSmall.copyWith(
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Shift cards
        ...shifts.map((shift) {
          final isSelected = selectedShift?.id == shift.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildShiftCard(
              context,
              ref,
              shift,
              isSelected,
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildShiftCard(
    BuildContext context,
    WidgetRef ref,
    model.Shift shift,
    bool isSelected,
  ) {
    // Determine morning/afternoon based on start time (before 12:00 = morning)
    final hour = int.tryParse(shift.startTime.split(':').first) ?? 0;
    final isMorning = hour < 12;

    return GestureDetector(
      onTap: () =>
          ref.read(shiftSelectionViewModelProvider.notifier).selectShift(shift),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isMorning ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift.name,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${shift.startTime} - ${shift.endTime}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.textLight,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirm(BuildContext context, WidgetRef ref, AppStrings strings) async {
    final selectedShift = ref.read(shiftSelectionViewModelProvider).selectedShift;
    if (selectedShift != null) {
      await ref.read(shiftSelectionViewModelProvider.notifier).confirmShift();

      if (context.mounted) {
        SnackBarUtils.success(context, strings.confirmShift);
        context.go(AppRoutes.profile);
      }
    }
  }
}
