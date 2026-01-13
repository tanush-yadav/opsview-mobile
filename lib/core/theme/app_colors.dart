import 'package:shadcn_flutter/shadcn_flutter.dart';

abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryDeep = Color(0xFF0F172A); // Dark Navy

  // Backgrounds
  static const Color backgroundLight = Color(0xFFE8E8E8);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF1A1A1A);

  // Text
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Sync Status
  static const Color synced = Color(0xFF22C55E);
  static const Color unsynced = Color(0xFFF59E0B);
  static const Color syncFailed = Color(0xFFEF4444);
  static const Color syncing = Color(0xFF3B82F6);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // Cards & Surfaces
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9FAFB);

  // Shadows
  static const Color shadow = Color(0x14000000); // 8% black
}
