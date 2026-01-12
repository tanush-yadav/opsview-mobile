import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import 'smart_image.dart';

/// A full-screen image viewer that displays an image with pinch-to-zoom.
class FullScreenImageViewer extends ConsumerWidget {
  const FullScreenImageViewer({super.key, required this.imagePath, this.title});

  final String imagePath;
  final String? title;

  /// Shows the full-screen image viewer as a modal route.
  static void show(BuildContext context, String imagePath, {String? title}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            FullScreenImageViewer(imagePath: imagePath, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: title != null
            ? Text(title!, style: const TextStyle(color: Colors.white))
            : null,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: SmartImage(
            path: imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surfaceLight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.broken_image,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ref.read(appStringsProvider).failedToLoadImage,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
