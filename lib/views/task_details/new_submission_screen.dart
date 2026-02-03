import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_strings.dart';
import '../../core/enums/location_status.dart';
import '../widgets/full_screen_image_viewer.dart';
import '../widgets/location_status_card.dart';
import '../widgets/location_permission_blocker_dialog.dart';
import '../widgets/smart_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task/captured_photo.dart';
import '../../models/task/checklist_item.dart';
import '../../models/task/image_checklist_entry.dart';
import '../../models/task/task_meta_data.dart';
import '../../viewmodels/new_submission_viewmodel.dart';

class NewSubmissionScreen extends ConsumerStatefulWidget {
  const NewSubmissionScreen({super.key, required this.taskId});
  final String taskId;

  @override
  ConsumerState<NewSubmissionScreen> createState() =>
      _NewSubmissionScreenState();
}

class _NewSubmissionScreenState extends ConsumerState<NewSubmissionScreen> {
  final TextEditingController _observationsController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  AppStrings get strings => ref.watch(appStringsProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newSubmissionViewModelProvider.notifier).loadTask(widget.taskId);
    });
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _takePhoto() {
    ref
        .read(newSubmissionViewModelProvider.notifier)
        .capturePhoto(ImageSource.camera);
  }

  void _removePhoto(int index) {
    ref.read(newSubmissionViewModelProvider.notifier).removePhoto(index);
  }

  void _takePhotoWithChecklist() {
    ref
        .read(newSubmissionViewModelProvider.notifier)
        .capturePhotoWithChecklist(ImageSource.camera);
  }

  void _removeImageChecklistEntry(int index) {
    ref
        .read(newSubmissionViewModelProvider.notifier)
        .removeImageChecklistEntry(index);
  }

  void _setImageChecklistAnswer(
    int imageIndex,
    int checklistIndex,
    String value,
  ) {
    ref
        .read(newSubmissionViewModelProvider.notifier)
        .setImageChecklistAnswer(imageIndex, checklistIndex, value);
  }

  void _updateObservations(String text) {
    ref.read(newSubmissionViewModelProvider.notifier).updateObservations(text);
  }

  Future<void> _submit() async {
    final success = await ref
        .read(newSubmissionViewModelProvider.notifier)
        .submitNewSubmission();
    if (success && mounted) {
      context.pop(true); // Return true to indicate successful submission
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newSubmissionViewModelProvider);
    final viewModel = ref.read(newSubmissionViewModelProvider.notifier);

    // Show blocker dialog if location permission is denied
    if (state.locationStatus == LocationStatus.permissionDenied) {
      return Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: LocationPermissionBlockerDialog(
          strings: strings,
          onRetry: viewModel.retryLocationDetection,
        ),
      );
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
                        if (state.metaData != null)
                          _buildInstructionsSection(state.metaData!),
                        const SizedBox(height: 24),
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
          _buildSubmitButton(state),
        ],
      ),
    );
  }

  Widget _buildHeader(NewSubmissionState state) {
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
                Text(strings.newSubmission, style: AppTextStyles.h3),
                Text(
                  state.task?.taskLabel ?? '',
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

  // ==================== IMAGE TASK UI ====================

  Widget _buildPhotoEvidenceSection(NewSubmissionState state) {
    final photos = state.capturedPhotos;
    final requiredCount = state.requiredImageCount;
    final hasReachedLimit = state.hasReachedImageLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSectionHeader(
                icon: Icons.camera_alt_outlined,
                title: strings.photoEvidence,
              ),
            ),
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
        if (!hasReachedLimit) _buildTakePhotoCard(photos.isNotEmpty),
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
                  strings.requiredPhotoCaptured,
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
        title: strings.photoN(index + 1),
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
              child: SmartImage(
                path: photo.imagePath,
                key: ValueKey(photo.imagePath),
                fit: BoxFit.cover,
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
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.zoom_in,
                      color: AppColors.textLight,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      strings.tapToView,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
              hasPhotos ? strings.addAnother : strings.takePhoto,
              style: AppTextStyles.h4.copyWith(fontSize: 16),
            ),
            if (!hasPhotos) ...[
              const SizedBox(height: 4),
              Text(strings.tapToCaptureEvidence, style: AppTextStyles.muted),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== CHECKLIST TASK UI ====================

  Widget _buildImageChecklistSection(NewSubmissionState state) {
    final entries = state.imageChecklistEntries;
    final hasEntries = entries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSectionHeader(
                icon: Icons.camera_alt_outlined,
                title: strings.photoVerification,
              ),
            ),
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
                strings.photosCount(entries.length),
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
        ...entries.asMap().entries.map((entry) {
          return _buildImageChecklistCard(entry.key, entry.value);
        }),
        _buildAddMoreCard(hasEntries),
      ],
    );
  }

  Widget _buildImageChecklistCard(int imageIndex, ImageChecklistEntry entry) {
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
          GestureDetector(
            onTap: () => FullScreenImageViewer.show(
              context,
              entry.localPath,
              title: strings.photoN(imageIndex + 1),
            ),
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                color: AppColors.textPrimary,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SmartImage(
                      path: entry.localPath,
                      key: ValueKey(entry.localPath),
                      fit: BoxFit.cover,
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
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        strings.photoN(imageIndex + 1),
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
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
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_in,
                            color: AppColors.textLight,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            strings.tapToView,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.checklist,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      strings.verification,
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

  Widget _buildChecklistItemForImage(
    int imageIndex,
    int checklistIndex,
    ChecklistItem item,
    int total,
  ) {
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
                        strings.mandatory,
                        style: AppTextStyles.muted.copyWith(
                          fontSize: 11,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 32),
              _buildChecklistOption(
                imageIndex,
                checklistIndex,
                'YES',
                item.value == 'YES',
                strings.yes,
              ),
              const SizedBox(width: 8),
              _buildChecklistOption(
                imageIndex,
                checklistIndex,
                'NO',
                item.value == 'NO',
                strings.no,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistOption(
    int imageIndex,
    int checklistIndex,
    String value,
    bool isSelected,
    String label,
  ) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      if (value == 'YES') {
        bgColor = AppColors.success;
        textColor = AppColors.textLight;
        borderColor = AppColors.success;
      } else if (value == 'NO') {
        bgColor = AppColors.error;
        textColor = AppColors.textLight;
        borderColor = AppColors.error;
      } else {
        bgColor = AppColors.textMuted;
        textColor = AppColors.textLight;
        borderColor = AppColors.textMuted;
      }
    } else {
      bgColor = AppColors.backgroundWhite;
      textColor = AppColors.textSecondary;
      borderColor = AppColors.border;
    }

    return GestureDetector(
      onTap: () => _setImageChecklistAnswer(imageIndex, checklistIndex, value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreCard(bool hasEntries) {
    return GestureDetector(
      onTap: _takePhotoWithChecklist,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: hasEntries ? 24 : 48),
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
                Icons.add_a_photo_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasEntries ? strings.addAnother : strings.takePhoto,
              style: AppTextStyles.h4.copyWith(fontSize: 16),
            ),
            if (!hasEntries) ...[
              const SizedBox(height: 4),
              Text(strings.tapToCaptureEvidence, style: AppTextStyles.muted),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== OBSERVATIONS ====================

  Widget _buildObservationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.notes_outlined,
          title: strings.observations,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _observationsController,
          maxLines: 4,
          onChanged: _updateObservations,
          decoration: InputDecoration(
            hintText: strings.addOptionalNotes,
            hintStyle: AppTextStyles.muted,
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  // ==================== SUBMIT BUTTON ====================

  Widget _buildSubmitButton(NewSubmissionState state) {
    final canSubmit = state.canSubmit && !state.isSubmitting;

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
          child: ElevatedButton(
            onPressed: canSubmit ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit
                  ? AppColors.primary
                  : AppColors.surfaceLight,
              foregroundColor: canSubmit
                  ? AppColors.textLight
                  : AppColors.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textLight,
                    ),
                  )
                : Text(
                    strings.submitTask,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
