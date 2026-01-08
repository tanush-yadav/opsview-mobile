/// Represents a photo captured for a task.
class CapturedPhoto {
  /// Local file path on device
  final String imagePath;

  /// Unique filename for API: {taskUUID}_{timestamp}_{sequence}.jpg
  final String filename;

  const CapturedPhoto({
    required this.imagePath,
    required this.filename,
  });
}
