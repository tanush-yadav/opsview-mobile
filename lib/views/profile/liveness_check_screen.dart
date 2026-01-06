import 'package:flutter/foundation.dart';
import 'package:flutter_liveness_detection_randomized_plugin/index.dart'
    hide Scaffold, CircularProgressIndicator;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/localization/app_strings.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../viewmodels/profile_viewmodel.dart';

class LivenessCheckPage extends ConsumerWidget {
  const LivenessCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    // Start liveness detection immediately when this page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLivenessDetection(context, ref, strings);
    });

    // Show a loading screen while the detection starts
    return const Scaffold(child: Center(child: CircularProgressIndicator()));
  }

  Future<void> _startLivenessDetection(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    try {
      // DEBUG BYPASS: Skip liveness detection on emulator/debug mode
      if (kDebugMode) {
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          // Use a placeholder path for debug - the actual selfie won't be uploaded
          ref.read(profileViewModelProvider.notifier).setSelfieImage(
            'debug_selfie_bypass',
            livenessScore: 0.95,
          );
          context.pop();
        }
        return;
      }

      final result = await FlutterLivenessDetectionRandomizedPlugin.instance
          .livenessDetection(
            context: context,
            config: LivenessDetectionConfig(
              startWithInfoScreen: false,
              isDarkMode: false,
              showCurrentStep: true,
              isEnableSnackBar: false,
              durationLivenessVerify: 60,
              shuffleListWithSmileLast: true,
              cameraResolution: ResolutionPreset.medium,
              imageQuality: 90,
              isEnableMaxBrightness: true,
              // Skip some challenges for faster verification
              useCustomizedLabel: true,
              customizedLabel: LivenessDetectionLabelModel(
                blink: null, // Use default "Blink"
                lookDown: '', // Skip look down
                lookLeft: null, // Use default
                lookRight: null, // Use default
                lookUp: '', // Skip look up
                smile: null, // Use default "Smile"
              ),
            ),
          );

      if (context.mounted) {
        if (result != null && result.isNotEmpty) {
          // Success - save the image path
          ref.read(profileViewModelProvider.notifier).setSelfieImage(result);
          context.pop();
        } else {
          // Failed or cancelled
          SnackBarUtils.error(context, strings.somethingWentWrong);
          context.pop();
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.error(context, strings.somethingWentWrong);
        context.pop();
      }
    }
  }
}
