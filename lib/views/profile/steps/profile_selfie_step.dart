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
import '../liveness_camera_screen.dart';

class ProfileSelfieStep extends ConsumerWidget {
  const ProfileSelfieStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final state = ref.watch(profileViewModelProvider);
    final viewModel = ref.read(profileViewModelProvider.notifier);

    return SingleChildScrollView(
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
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: state.selfieImagePath != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(state.selfieImagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      // Liveness score badge
                      if (state.livenessScore != null)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Liveness: ${(state.livenessScore! * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                      onPressed: () => _handleRetake(context, ref, strings),
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

  Future<void> _handleRetake(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    // Clear existing selfie first
    ref.read(profileViewModelProvider.notifier).clearSelfie();
    // Immediately open camera for new capture
    await _handleCapture(context, ref, strings);
  }

  Future<void> _handleCapture(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    // Navigate to liveness camera screen
    final result = await Navigator.of(context).push<LivenessResult>(
      MaterialPageRoute(
        builder: (context) => const LivenessCameraScreen(),
      ),
    );

    if (result != null) {
      // Liveness passed, save the result
      ref.read(profileViewModelProvider.notifier).setLivenessCameraResult(
        result.imagePath,
        result.livenessScore,
      );
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
        // Show actual error message for debugging
        SnackBarUtils.error(context, e.toString());
      }
    }
  }
}
