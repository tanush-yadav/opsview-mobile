import 'dart:io';

import 'package:flutter/material.dart';

/// A widget that displays an image from either a local file path or a network URL.
/// Automatically detects the type based on the path prefix.
class SmartImage extends StatelessWidget {
  const SmartImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
    this.width,
    this.height,
  });

  final String path;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final double? width;
  final double? height;

  /// Checks if the path is a network URL
  bool get isNetworkPath =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (isNetworkPath) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
        loadingBuilder:
            loadingBuilder ??
            (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
      );
    } else {
      return Image.file(
        File(path),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
      );
    }
  }
}
