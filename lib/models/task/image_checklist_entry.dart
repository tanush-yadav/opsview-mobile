import 'checklist_item.dart';

/// Entry representing an image with its associated checklist answers.
/// Used for CHECKLIST type tasks where each image has its own checklist.
class ImageChecklistEntry {

  factory ImageChecklistEntry.fromJson(Map<String, dynamic> json, [String? overrideLocalPath]) {
    final checklistList = json['checklist'] as List<dynamic>? ?? [];
    return ImageChecklistEntry(
      filename: json['filename'] ?? '',
      localPath: overrideLocalPath ?? json['localPath'] ?? '',
      checklist: checklistList.map((e) => ChecklistItem.fromJson(e)).toList(),
    );
  }
  ImageChecklistEntry({
    required this.filename,
    required this.localPath,
    required this.checklist,
  });

  /// Unique filename for API: {taskUUID}_{timestamp}_{sequence}.jpg
  final String filename;

  /// Local file path on device
  final String localPath;

  /// Checklist answers for this specific image
  final List<ChecklistItem> checklist;

  /// Create a copy with updated checklist
  ImageChecklistEntry copyWith({List<ChecklistItem>? checklist}) {
    return ImageChecklistEntry(
      filename: filename,
      localPath: localPath,
      checklist: checklist ?? this.checklist,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'localPath': localPath,
      'checklist': checklist.map((e) => e.toJson()).toList(),
    };
  }
}
