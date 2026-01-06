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
import '../../widgets/location_status_card.dart';

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
          LocationStatusCard(
            status: state.locationStatus,
            formattedDistance: state.formattedDistance,
            strings: strings,
            onRetry: viewModel.retryLocationDetection,
          ),
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
                        Text(strings.capturePhoto, style: AppTextStyles.muted),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          if (state.selfieImagePath != null) ...[
            // Selfie captured - show Retake and Submit buttons
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
            // No selfie yet - show Capture button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: PrimaryButton(
                onPressed: state.isLocationValid && !state.isLoading
                    ? () => _handleCapture(context, ref, strings)
                    : null,
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : Row(
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

  Future<void> _handleCapture(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    try {
      await ref
          .read(profileViewModelProvider.notifier)
          .captureAndVerifySelfie();
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.error(context, e.toString());
      }
    }
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
