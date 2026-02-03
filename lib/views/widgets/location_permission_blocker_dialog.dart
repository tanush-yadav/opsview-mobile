import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A blocking dialog that shows when location permission is denied.
/// Guides the user to enable location in device settings.
class LocationPermissionBlockerDialog extends StatelessWidget {
  const LocationPermissionBlockerDialog({
    super.key,
    required this.strings,
    required this.onRetry,
  });

  final AppStrings strings;
  final VoidCallback onRetry;

  Future<void> _openSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Location icon with error state
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_off_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                strings.locationPermissionRequired,
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                strings.locationPermissionDeniedMessage,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Open Settings button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings, size: 20),
                  label: Text(
                    strings.openSettings,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Retry button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: Text(
                    strings.retry,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
