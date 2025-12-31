import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../viewmodels/profile_viewmodel.dart';

class LivenessCheckPage extends ConsumerWidget {
  const LivenessCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final viewModel = ref.read(profileViewModelProvider.notifier);

    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        appBarConfig: AppBarConfig(
          title: strings.faceVerification,
          showBackButton: true,
        ),
        callbacks: LivenessCheckCallbacks(
          onPhotoTaken: (imagePath, antiSpoofingPassed) {
            viewModel.setSelfieImage(imagePath);
            if (context.mounted) {
              context.pop();
            }
          },
          onCancel: () {
            if (context.mounted) {
              context.pop();
            }
          },
          onError: (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              context.pop();
            }
          },
          onTryAgain: () {
            // User wants to retry - stay on this screen
          },
        ),
      ),
    );
  }
}
