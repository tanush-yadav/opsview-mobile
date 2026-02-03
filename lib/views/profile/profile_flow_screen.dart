import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/profile_viewmodel.dart';
import 'steps/profile_details_step.dart';
import 'steps/profile_selfie_step.dart';

class ProfileFlowScreen extends ConsumerStatefulWidget {
  const ProfileFlowScreen({super.key});

  @override
  ConsumerState<ProfileFlowScreen> createState() => _ProfileFlowScreenState();
}

class _ProfileFlowScreenState extends ConsumerState<ProfileFlowScreen> {
  bool _hasCheckedProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingProfile();
    });
  }

  void _checkExistingProfile() {
    if (_hasCheckedProfile) return;
    _hasCheckedProfile = true;

    final appState = ref.read(appStateProvider);
    final selectedShiftId = appState.selectedShiftId;
    final profiles = appState.profiles;

    // If a profile already exists for this shift, skip to home
    if (profiles.isNotEmpty &&
        selectedShiftId != null &&
        profiles.any((p) => p.shiftId == selectedShiftId)) {
      debugPrint(
        '[ProfileFlow] Profile exists for shift $selectedShiftId, skipping to home',
      );
      context.push(AppRoutes.training);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: SafeArea(
        child: Column(
          children: [
            // Step indicator
            _buildStepIndicator(context, ref, state),
            const Divider(color: AppColors.border),
            // Content
            Expanded(
              child: state.currentStep == ProfileStep.details
                  ? const ProfileDetailsStep()
                  : const ProfileSelfieStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    WidgetRef ref,
    ProfileState state,
  ) {
    final strings = ref.watch(appStringsProvider);
    final isStep1Active = state.currentStep == ProfileStep.details;
    final isStep2Active = state.currentStep == ProfileStep.selfie;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              if (isStep2Active) {
                // Go back to details step
                ref.read(profileViewModelProvider.notifier).goToDetails();
              } else {
                // Go back to shift selection
                context.go(AppRoutes.shiftSelection);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLight,
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Step 1
          _buildStepCircle(
            number: '1',
            isActive: isStep1Active,
            isCompleted: isStep2Active,
          ),
          const SizedBox(width: 8),
          Text(
            strings.details,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isStep1Active || isStep2Active
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
          ),
          // Line
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: isStep2Active ? AppColors.primary : AppColors.border,
            ),
          ),
          // Step 2
          _buildStepCircle(
            number: '2',
            isActive: isStep2Active,
            isCompleted: false,
          ),
          const SizedBox(width: 8),
          Text(
            strings.selfie,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isStep2Active ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle({
    required String number,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive || isCompleted ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isActive || isCompleted ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 18, color: AppColors.textLight)
            : Text(
                number,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.textLight : AppColors.textMuted,
                ),
              ),
      ),
    );
  }
}
