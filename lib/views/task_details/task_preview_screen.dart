import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../widgets/full_screen_image_viewer.dart';
import '../widgets/smart_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task/checklist_item.dart';
import '../../models/task/image_checklist_entry.dart';
import '../../models/task/task_meta_data.dart';
import '../../viewmodels/task_preview_viewmodel.dart';
import '../../core/router/app_router.dart';

class TaskPreviewScreen extends ConsumerStatefulWidget {
  const TaskPreviewScreen({super.key, required this.taskId});
  final String taskId;

  @override
  ConsumerState<TaskPreviewScreen> createState() => _TaskPreviewScreenState();
}

class _TaskPreviewScreenState extends ConsumerState<TaskPreviewScreen> {
  final ScrollController _scrollController = ScrollController();

  AppStrings get strings => ref.watch(appStringsProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskPreviewViewModelProvider.notifier).loadTask(widget.taskId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addNewSubmission() async {
    final result = await context.push<bool>(
      '${AppRoutes.taskPreview}/${widget.taskId}/new',
    );
    if (result == true) {
      // Reload to show the new submission
      ref.read(taskPreviewViewModelProvider.notifier).reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskPreviewViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Column(
        children: [
          SafeArea(bottom: false, child: _buildHeader(state)),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        if (state.metaData != null)
                          _buildInstructionsSection(state.metaData!),
                        const SizedBox(height: 24),
                        _buildSubmissionsSection(state),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
          _buildAddSubmissionButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(TaskPreviewState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.backgroundWhite,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.task?.taskLabel ?? strings.taskDetails,
                  style: AppTextStyles.h3,
                ),
                Text(
                  state.task?.centerName ?? '',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSection(TaskMetaData metaData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.format_list_numbered,
          title: metaData.taskInstructionHeader.toUpperCase(),
        ),
        if (metaData.taskInstructionSubHeader.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(metaData.taskInstructionSubHeader, style: AppTextStyles.muted),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: metaData.taskInstructionSet.asMap().entries.map((entry) {
              final index = entry.key;
              final instruction = entry.value;
              final isLast = index == metaData.taskInstructionSet.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(instruction, style: AppTextStyles.body),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmissionsSection(TaskPreviewState state) {
    if (!state.hasSubmissions) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.history,
          title: strings.previousSubmission,
        ),
        const SizedBox(height: 12),
        ...state.submissions.asMap().entries.map((entry) {
          return _buildSubmissionCard(entry.key, entry.value, state);
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(strings.noSubmissionsYet, style: AppTextStyles.h4),
          const SizedBox(height: 8),
          Text(
            strings.tapToAddFirstSubmission,
            style: AppTextStyles.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(
    int index,
    SubmissionPreview submission,
    TaskPreviewState state,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        color: AppColors.cardBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Images
          if (submission.imagePaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: submission.imagePaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, imgIndex) {
                    final path = submission.imagePaths[imgIndex];
                    return GestureDetector(
                      onTap: () => FullScreenImageViewer.show(
                        context,
                        path,
                        title: strings.photoN(imgIndex + 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: SmartImage(
                            path: path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.surfaceLight,
                                child: const Icon(
                                  Icons.image,
                                  color: AppColors.textMuted,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          // Checklist entries (if CHECKLIST task)
          if (state.isChecklistTask && submission.checklistEntries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _buildChecklistPreview(submission.checklistEntries.first),
            ),
          // Observations
          if (submission.observations != null &&
              submission.observations!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                submission.imagePaths.isEmpty ? 12 : 0,
                12,
                12,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${strings.notes}:',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(submission.observations!, style: AppTextStyles.body),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChecklistPreview(ImageChecklistEntry entry) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${strings.verification}:',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ...entry.checklist.map((item) => _buildChecklistItemPreview(item)),
        ],
      ),
    );
  }

  Widget _buildChecklistItemPreview(ChecklistItem item) {
    Color valueColor;
    IconData valueIcon;

    switch (item.value) {
      case 'YES':
        valueColor = AppColors.success;
        valueIcon = Icons.check_circle;
        break;
      case 'NO':
        valueColor = AppColors.error;
        valueIcon = Icons.cancel;
        break;
      default:
        valueColor = AppColors.textMuted;
        valueIcon = Icons.remove_circle_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(valueIcon, size: 16, color: valueColor),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(item.question, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildAddSubmissionButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _addNewSubmission,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(
              strings.addNewSubmission,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}
