import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/auth/shift.dart';
import '../../viewmodels/training_viewmodel.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingState();
  }

  void _checkOnboardingState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = ref.read(appStateProvider);
      final currentStep = OnboardingStep.fromString(appState.onboardingStep);

      // If onboarding step is not 'training', redirect to appropriate screen
      if (currentStep != OnboardingStep.training) {
        if (currentStep == OnboardingStep.completed) {
          context.push(AppRoutes.home);
        } else if (currentStep == OnboardingStep.profile) {
          context.push(AppRoutes.profile);
        }
        // For other states, stay on this screen (shouldn't happen normally)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final trainingState = ref.watch(trainingViewModelProvider);
    final trainingViewModel = ref.read(trainingViewModelProvider.notifier);

    final trainingService = trainingState.currentService;

    return Scaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(strings.trainingRequired, style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                strings.completeBeforeShiftStart,
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Video Card
              if (trainingService != null)
                _buildVideoCard(trainingService, strings, trainingViewModel),

              const Spacer(),

              // Complete Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: PrimaryButton(
                  onPressed: () async {
                    await trainingViewModel.completeTraining();
                    if (context.mounted) {
                      context.go(AppRoutes.home);
                    }
                  },
                  child: Text(
                    strings.completed,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Skip Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    if (context.mounted) {
                      context.go(AppRoutes.home);
                    }
                  },
                  child: Text(
                    strings.skip,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
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

  Widget _buildVideoCard(
    ShiftService service,
    AppStrings strings,
    TrainingViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.openTrainingVideo(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail with Play Button
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            // Video Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name.isNotEmpty
                        ? service.name
                        : 'Morning Shift SOP',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
