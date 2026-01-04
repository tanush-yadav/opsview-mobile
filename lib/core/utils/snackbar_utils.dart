import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../theme/app_colors.dart';

enum ToastType { success, error, warning, info }

class SnackBarUtils {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
  }) {
    showToast(
      context: context,
      builder: (context, overlay) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: SurfaceCard(
            child: Basic(
              leading: Icon(_getIcon(type), color: _getColor(type), size: 20),
              title: Text(message),
            ),
          ),
        );
      },
      location: ToastLocation.bottomCenter,
      showDuration: const Duration(seconds: 2),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: ToastType.info);
  }

  static Color _getColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.info;
    }
  }

  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }
}
