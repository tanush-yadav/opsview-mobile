import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/enums/location_status.dart';

class LocationStatusCard extends StatelessWidget {
  const LocationStatusCard({
    super.key,
    required this.status,
    required this.formattedDistance,
    required this.strings,
    required this.onRetry,
    this.isInsideGeofence = false,
  });

  final LocationStatus status;
  final String formattedDistance;
  final AppStrings strings;
  final VoidCallback onRetry;
  final bool isInsideGeofence;

  @override
  Widget build(BuildContext context) {
    final isDetecting = status == LocationStatus.detecting;
    final isDetected = status == LocationStatus.detected;
    final isError = status == LocationStatus.error;

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
                          formattedDistance,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Inside/Outside geofence indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isInsideGeofence
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isInsideGeofence
                            ? AppColors.success.withValues(alpha: 0.5)
                            : AppColors.warning.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isInsideGeofence
                              ? Icons.check_circle
                              : Icons.warning_amber_rounded,
                          size: 16,
                          color: isInsideGeofence
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isInsideGeofence ? 'Inside Zone' : 'Outside Zone',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isInsideGeofence
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Retry button for error state
          if (isError)
            GestureDetector(
              onTap: onRetry,
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
}
