import 'checklist_item.dart';

/// Represents a URL entry in the urls array
class SubmissionUrl {
  SubmissionUrl({required this.fileName, required this.url});

  factory SubmissionUrl.fromJson(Map<String, dynamic> json) {
    return SubmissionUrl(
      fileName: json['fileName'] ?? '',
      url: json['url'] ?? '',
    );
  }

  final String fileName;
  final String url;

  Map<String, dynamic> toJson() => {'fileName': fileName, 'url': url};
}

/// Represents a task submission from the backend API response.
/// This is used when fetching tasks to display previous submissions.
class TaskSubmissionResponse {
  TaskSubmissionResponse({
    required this.id,
    this.urls,
    this.message,
    this.lat,
    this.lng,
    this.fenceStatus,
    this.distFromCenter,
    this.location,
    this.syncedAt,
    this.checklist,
  });

  factory TaskSubmissionResponse.fromJson(Map<String, dynamic> json) {
    // Parse urls array
    List<SubmissionUrl>? urls;
    if (json['urls'] != null) {
      urls = (json['urls'] as List)
          .map((e) => SubmissionUrl.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse checklist array
    List<ChecklistItem>? checklist;
    if (json['checklist'] != null) {
      checklist = (json['checklist'] as List)
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TaskSubmissionResponse(
      id: json['id'] ?? '',
      urls: urls,
      message: json['message'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      fenceStatus: json['fenceStatus'],
      distFromCenter: (json['distFromCenter'] as num?)?.toDouble(),
      location: json['location'],
      syncedAt: json['syncedAt'] != null
          ? DateTime.tryParse(json['syncedAt'])
          : null,
      checklist: checklist,
    );
  }

  final String id;
  final List<SubmissionUrl>? urls;
  final String? message;
  final double? lat;
  final double? lng;
  final String? fenceStatus;
  final double? distFromCenter;
  final String? location;
  final DateTime? syncedAt;
  final List<ChecklistItem>? checklist;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'urls': urls?.map((e) => e.toJson()).toList(),
      'message': message,
      'lat': lat,
      'lng': lng,
      'fenceStatus': fenceStatus,
      'distFromCenter': distFromCenter,
      'location': location,
      'syncedAt': syncedAt?.toIso8601String(),
      'checklist': checklist?.map((e) => e.toJson()).toList(),
    };
  }
}
