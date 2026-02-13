import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/confirmation_viewmodel.dart';

class ConfirmationScreen extends ConsumerWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Title
                      Text(strings.confirmationTitle, style: AppTextStyles.h1),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        strings.verifyAssignment,
                        style: AppTextStyles.muted,
                      ),
                      const Divider(height: 32, color: AppColors.border),
                      const SizedBox(height: 16),
                      // Details Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 24,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Exam Code
                            _buildDetailItem(
                              label: strings.examCodeLabel,
                              value: appState.exam?.code ?? '',
                            ),
                            const SizedBox(height: 16),
                            // Exam Name
                            _buildDetailItem(
                              label: strings.examNameLabel,
                              value: appState.exam?.name ?? '',
                            ),
                            const SizedBox(height: 16),
                            // Center Code
                            _buildDetailItem(
                              label: strings.centerCodeLabel,
                              value: appState.center?.code ?? '',
                            ),
                            const SizedBox(height: 16),
                            // Center Name
                            _buildDetailItem(
                              label: strings.centerNameLabel,
                              value: appState.center?.name ?? '',
                              icon: Icons.location_on_outlined,
                              iconColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Buttons
              Row(
                children: [
                  // Wrong Center Button
                  Expanded(
                    child: material.OutlinedButton(
                        onPressed: () => _handleWrongCenter(context, ref),
                        style: material.OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.close,
                                size: 20,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                strings.wrongCenter,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Yes, Confirm Button
                  Expanded(
                    child: material.ElevatedButton(
                        onPressed: () => _handleConfirm(context, ref),
                        style: material.ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.textLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 0,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 20,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                strings.yesConfirm,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    IconData? icon,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor ?? AppColors.textMuted),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleWrongCenter(BuildContext context, WidgetRef ref) async {
    await ref.read(confirmationViewModelProvider.notifier).clearSession();

    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _handleConfirm(BuildContext context, WidgetRef ref) async {

    await ref.read(confirmationViewModelProvider.notifier).confirmCenter();

    if (context.mounted) {
      context.go(AppRoutes.shiftSelection);
    }
  }
}
