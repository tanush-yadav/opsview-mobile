import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../viewmodels/profile_viewmodel.dart';

class ProfileSelfieStep extends ConsumerWidget {
  const ProfileSelfieStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final state = ref.watch(profileViewModelProvider);
    final viewModel = ref.read(profileViewModelProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(strings.verifyLocationAndSelfie, style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(strings.ensureInsideExamCentre, style: AppTextStyles.muted),
          const SizedBox(height: 24),
          // Location Status Card
          _buildLocationCard(state, strings, viewModel),
          const SizedBox(height: 24),
          // Camera preview / captured image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: state.selfieImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(state.selfieImagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          strings.capturePhoto,
                          style: AppTextStyles.muted,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          if (state.selfieImagePath != null) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlineButton(
                      onPressed: viewModel.clearSelfie,
                      child: Text(strings.retake),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: PrimaryButton(
                      onPressed: state.isLoading || !state.isLocationValid
                          ? null
                          : () => _handleSubmit(context, ref, strings),
                      child: state.isLoading
                          ? const CircularProgressIndicator()
                          : Text(strings.submit),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: PrimaryButton(
                onPressed: state.isLocationValid
                    ? () => context.push(AppRoutes.livenessCheck)
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      strings.capturePhoto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    ProfileState state,
    AppStrings strings,
    ProfileViewModel viewModel,
  ) {
    final isDetecting = state.locationStatus == LocationStatus.detecting;
    final isDetected = state.locationStatus == LocationStatus.detected;
    final isError = state.locationStatus == LocationStatus.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDetected
            ? AppColors.success.withValues(alpha: 0.1)
            : isError
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDetected
              ? AppColors.success.withValues(alpha: 0.3)
              : isError
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Location Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDetected
                  ? AppColors.success.withValues(alpha: 0.2)
                  : isError
                      ? AppColors.error.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Center(
              child: isDetecting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      isDetected
                          ? Icons.location_on
                          : isError
                              ? Icons.location_off
                              : Icons.location_searching,
                      size: 24,
                      color: isDetected
                          ? AppColors.success
                          : isError
                              ? AppColors.error
                              : AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Location Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDetecting
                      ? strings.detectingLocation
                      : isDetected
                          ? strings.locationDetected
                          : strings.locationNotDetected,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDetected
                        ? AppColors.success
                        : isError
                            ? AppColors.error
                            : AppColors.textPrimary,
                  ),
                ),
                if (isDetected) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        strings.distanceFromCentre,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          state.formattedDistance,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Retry button for error state
          if (isError)
            GestureDetector(
              onTap: viewModel.retryLocationDetection,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.refresh,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    try {
      await ref.read(profileViewModelProvider.notifier).submitProfile();

      if (context.mounted) {
        context.go(AppRoutes.training);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.error(context, strings.somethingWentWrong);
      }
    }
  }
}
