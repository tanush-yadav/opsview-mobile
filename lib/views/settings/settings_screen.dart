import 'dart:io';

import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/localization/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Text(strings.profile, style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(strings.operatorAssignmentDetails, style: AppTextStyles.muted),
                          const SizedBox(height: 24),
                          // Operator Identity Section
                          _buildSectionHeader(Icons.person_outline, strings.operatorIdentity),
                          const SizedBox(height: 12),
                          _buildIdentityCard(state, strings),
                          const SizedBox(height: 24),
                          // Current Assignment Section
                          _buildSectionHeader(Icons.check_circle_outline, strings.currentAssignment),
                          const SizedBox(height: 12),
                          _buildAssignmentCard(
                            icon: Icons.description_outlined,
                            title: state.exam?.name ?? '',
                            subtitle: '${strings.examCodeLabel}: #${state.exam?.code ?? ''}',
                          ),
                          const SizedBox(height: 8),
                          _buildAssignmentCard(
                            icon: Icons.location_on_outlined,
                            title: state.center?.name ?? '',
                            subtitle: '${state.center?.city ?? ''} • ${state.center?.code ?? ''}',
                          ),
                          const SizedBox(height: 8),
                          _buildAssignmentCard(
                            icon: Icons.fingerprint,
                            title: state.service ?? 'Biometric',
                            subtitle: strings.assignedService,
                          ),
                          const SizedBox(height: 24),
                          // Training Section
                          _buildSectionHeader(Icons.play_circle_outline, strings.training),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: viewModel.openTrainingVideo,
                            child: _buildAssignmentCard(
                              icon: Icons.play_circle_outline,
                              title: strings.trainingModule,
                              subtitle: strings.viewBriefingVideo,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Section
                  _buildBottomSection(context, state, viewModel, strings),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            letterSpacing: 1.2,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityCard(SettingsState state, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surfaceLight,
            ),
            child: state.profile?.selfieLocalPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(state.profile!.selfieLocalPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person, size: 48, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            state.profile?.name ?? '',
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          // Role
          Text(state.userRole, style: AppTextStyles.body),
          const SizedBox(height: 12),
          // Info chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip('ID: ${state.user?.id.substring(0, 8) ?? ''}'),
              const SizedBox(width: 8),
              if (state.profile != null) _buildInfoChip('${strings.age}: ${state.profile!.age}'),
              const SizedBox(width: 8),
              _buildStatusChip(strings.onDuty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: AppTextStyles.bodySmall),
    );
  }

  Widget _buildStatusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAssignmentCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h4),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    SettingsState state,
    SettingsViewModel viewModel,
    AppStrings strings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Sync Warning
          if (state.hasPendingSync)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.syncRequired,
                          style: AppTextStyles.label.copyWith(color: AppColors.warning),
                        ),
                        Text(
                          strings.syncBeforeLogout,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Sync Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: material.OutlinedButton(
              onPressed: state.isSyncing ? null : viewModel.syncData,
              style: material.OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: state.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sync, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          strings.syncData,
                          style: AppTextStyles.button.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: material.OutlinedButton(
              onPressed: state.hasPendingSync
                  ? null
                  : () async {
                      await viewModel.logout();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
              style: material.OutlinedButton.styleFrom(
                side: BorderSide(
                  color: state.hasPendingSync ? AppColors.textMuted : AppColors.border,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    color: state.hasPendingSync ? AppColors.textMuted : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strings.logout,
                    style: AppTextStyles.button.copyWith(
                      color: state.hasPendingSync ? AppColors.textMuted : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
