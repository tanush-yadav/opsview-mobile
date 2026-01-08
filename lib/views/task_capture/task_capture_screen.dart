import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_strings.dart';
import '../widgets/full_screen_image_viewer.dart';
import '../widgets/location_status_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task/captured_photo.dart';
import '../../models/task/checklist_item.dart';
import '../../models/task/image_checklist_entry.dart';
import '../../models/task/task_meta_data.dart';
import '../../viewmodels/task_capture_viewmodel.dart';

class TaskCaptureScreen extends ConsumerStatefulWidget {
  const TaskCaptureScreen({super.key, required this.taskId});
  final String taskId;

  @override
  ConsumerState<TaskCaptureScreen> createState() => _TaskCaptureScreenState();
}

class _TaskCaptureScreenState extends ConsumerState<TaskCaptureScreen> {
  final TextEditingController _observationsController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _observationsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear observations controller and reset flag before loading new task
      _observationsController.clear();
      _observationsInitialized = false;
      ref.read(taskCaptureViewModelProvider.notifier).loadTask(widget.taskId);
    });
  }

  @override
  void deactivate() {
    ref.invalidate(taskCaptureViewModelProvider);
    super.deactivate();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==================== IMAGE TASK METHODS ====================

  void _takePhoto() {
    ref.read(taskCaptureViewModelProvider.notifier).capturePhoto(ImageSource.camera);
  }

  void _removePhoto(int index) {
    ref.read(taskCaptureViewModelProvider.notifier).removePhoto(index);
  }

  // ==================== CHECKLIST TASK METHODS ====================

  void _takePhotoWithChecklist() {
    ref.read(taskCaptureViewModelProvider.notifier).capturePhotoWithChecklist(ImageSource.camera);
  }

  void _removeImageChecklistEntry(int index) {
    ref.read(taskCaptureViewModelProvider.notifier).removeImageChecklistEntry(index);
  }

  void _setImageChecklistAnswer(int imageIndex, int checklistIndex, String value) {
    ref.read(taskCaptureViewModelProvider.notifier).setImageChecklistAnswer(imageIndex, checklistIndex, value);
  }

  // ==================== COMMON METHODS ====================

  void _updateObservations(String text) {
    ref.read(taskCaptureViewModelProvider.notifier).updateObservations(text);
  }

  Future<void> _completeTask() async {
    final viewModel = ref.read(taskCaptureViewModelProvider.notifier);
    final success = await viewModel.completeTask();
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskCaptureViewModelProvider);
    final strings = ref.watch(appStringsProvider);
    final viewModel = ref.read(taskCaptureViewModelProvider.notifier);

    // Sync observations controller when state loads for the first time
    if (!_observationsInitialized && state.observations.isNotEmpty) {
      _observationsInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _observationsController.text = state.observations;
      });
    }

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
                        LocationStatusCard(
                          status: state.locationStatus,
                          formattedDistance: state.formattedDistance,
                          strings: strings,
                          onRetry: viewModel.retryLocationDetection,
                          isInsideGeofence: state.isInsideGeofence,
                        ),
                        const SizedBox(height: 24),
                        // Show instructions from metaData if available
                        if (state.metaData != null)
                          _buildInstructionsSection(state.metaData!),
                        const SizedBox(height: 24),
                        // Conditionally show IMAGE or CHECKLIST content
                        if (state.isImageTask) ...[
                          _buildPhotoEvidenceSection(state),
                          const SizedBox(height: 24),
                        ],
                        if (state.isChecklistTask) ...[
                          _buildImageChecklistSection(state),
                          const SizedBox(height: 24),
                        ],
                        _buildObservationsSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
          _buildBottomButton(state),
        ],
      ),
    );
  }

  Widget _buildHeader(TaskCaptureState state) {
    final task = state.task;
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
                  task?.taskLabel ?? 'Task Details',
                  style: AppTextStyles.h3,
                ),
                Text(task?.centerName ?? '', style: AppTextStyles.bodySmall),
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

  // ==================== IMAGE TASK UI ====================

  Widget _buildPhotoEvidenceSection(TaskCaptureState state) {
    final photos = state.capturedPhotos;
    final requiredCount = state.requiredImageCount;
    final hasReachedLimit = state.hasReachedImageLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with photo count
        Row(
          children: [
            Expanded(
              child: _buildSectionHeader(
                icon: Icons.camera_alt_outlined,
                title: 'PHOTO EVIDENCE',
              ),
            ),
            // Photo count indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: hasReachedLimit
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasReachedLimit
                      ? AppColors.success.withValues(alpha: 0.5)
                      : AppColors.warning.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                '${photos.length}/$requiredCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasReachedLimit
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...photos.asMap().entries.map((entry) {
          return _buildCapturedPhotoCard(entry.key, entry.value);
        }),
        // Only show "Take Photo" if limit not reached
        if (!hasReachedLimit) _buildTakePhotoCard(photos.isNotEmpty),
        // Show completion message if limit reached
        if (hasReachedLimit)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Required photo captured',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCapturedPhotoCard(int index, CapturedPhoto photo) {
    return GestureDetector(
      onTap: () => FullScreenImageViewer.show(
        context,
        photo.imagePath,
        title: 'Photo ${index + 1}',
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.textPrimary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(photo.imagePath),
                key: ValueKey(photo.imagePath),
                fit: BoxFit.cover,
                gaplessPlayback: false,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primaryDark.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: AppColors.textLight.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Tap to view hint
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in, color: AppColors.textLight, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Tap to view',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removePhoto(index),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textLight,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTakePhotoCard(bool hasPhotos) {
    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: hasPhotos ? 24 : 48),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasPhotos ? 'Add Another' : 'Take Photo',
              style: AppTextStyles.h4.copyWith(fontSize: 16),
            ),
            if (!hasPhotos) ...[
              const SizedBox(height: 4),
              Text('Tap to capture evidence', style: AppTextStyles.muted),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== CHECKLIST TASK UI (IMAGE + PER-IMAGE CHECKLIST) ====================

  Widget _buildImageChecklistSection(TaskCaptureState state) {
    final entries = state.imageChecklistEntries;
    final hasEntries = entries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: _buildSectionHeader(
                icon: Icons.camera_alt_outlined,
                title: 'PHOTO VERIFICATION',
              ),
            ),
            // Photo count indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: hasEntries
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasEntries
                      ? AppColors.success.withValues(alpha: 0.5)
                      : AppColors.warning.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                '${entries.length} photo${entries.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasEntries ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Image + Checklist entries
        ...entries.asMap().entries.map((entry) {
          return _buildImageChecklistCard(entry.key, entry.value);
        }),
        
        // Add More button (always visible for CHECKLIST tasks)
        _buildAddMoreCard(hasEntries),
      ],
    );
  }

  Widget _buildImageChecklistCard(int imageIndex, ImageChecklistEntry entry) {
    // Debug: Print the path being used for each image
    print('Building card $imageIndex with path: ${entry.localPath}');
    
    return Container(
      key: ValueKey('image_card_${entry.filename}_$imageIndex'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        color: AppColors.cardBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview with delete button
          GestureDetector(
            onTap: () => FullScreenImageViewer.show(
              context,
              entry.localPath,
              title: 'Photo ${imageIndex + 1}',
            ),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: AppColors.textPrimary,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.file(
                      File(entry.localPath),
                      key: ValueKey(entry.localPath),
                      fit: BoxFit.cover,
                      gaplessPlayback: false,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.3),
                                AppColors.primaryDark.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: AppColors.textLight.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Photo number badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Photo ${imageIndex + 1}',
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Delete button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeImageChecklistEntry(imageIndex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.textLight,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Tap to view hint
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: AppColors.textLight, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Tap to view',
                            style: TextStyle(color: AppColors.textLight, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Checklist for this image
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.checklist, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Verification',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...entry.checklist.asMap().entries.map((checkEntry) {
                  return _buildChecklistItemForImage(
                    imageIndex,
                    checkEntry.key,
                    checkEntry.value,
                    entry.checklist.length,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItemForImage(int imageIndex, int checklistIndex, ChecklistItem item, int total) {
    return Padding(
      padding: EdgeInsets.only(bottom: checklistIndex < total - 1 ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${checklistIndex + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.question, style: AppTextStyles.body),
                    if (item.required)
                      Text(
                        'Required',
                        style: AppTextStyles.mutedSmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: [
                Expanded(
                  child: _buildAnswerButton(
                    label: 'Yes',
                    isSelected: item.value == 'YES',
                    onTap: () => _setImageChecklistAnswer(imageIndex, checklistIndex, 'YES'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAnswerButton(
                    label: 'No',
                    isSelected: item.value == 'NO',
                    onTap: () => _setImageChecklistAnswer(imageIndex, checklistIndex, 'NO'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreCard(bool hasPhotos) {
    return GestureDetector(
      onTap: _takePhotoWithChecklist,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: hasPhotos ? 20 : 40),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hasPhotos ? 'Add More Photos' : 'Add Photo',
              style: AppTextStyles.h4.copyWith(fontSize: 15),
            ),
            if (!hasPhotos) ...[
              const SizedBox(height: 4),
              Text('Capture photo and answer verification', style: AppTextStyles.muted),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildObservationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.description_outlined,
          title: 'OBSERVATIONS',
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary),
          ),
          child: TextField(
            controller: _observationsController,
            maxLines: 4,
            style: AppTextStyles.body,
            onChanged: _updateObservations,
            decoration: InputDecoration(
              hintText: 'Add any notes or observations...',
              hintStyle: AppTextStyles.muted,
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(TaskCaptureState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: state.canComplete ? _completeTask : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            disabledBackgroundColor: AppColors.border,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
          child: Text(
            'Submit Task',
            style: AppTextStyles.button.copyWith(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
