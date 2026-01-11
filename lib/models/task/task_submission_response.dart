/// Represents a task submission from the backend API response.
/// This is used when fetching tasks to display previous submissions.
class TaskSubmissionResponse {
  TaskSubmissionResponse({
    required this.id,
    this.imageUrl,
    this.message,
    this.submittedAt,
    this.verificationAnswers,
    this.fenceStatus,
    this.distFromCenter,
    this.location,
  });

  factory TaskSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return TaskSubmissionResponse(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? json['url'],
      message: json['message'] ?? json['taskMessage'],
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
      verificationAnswers: json['verificationAnswers'],
      fenceStatus: json['fenceStatus'],
      distFromCenter: (json['distFromCenter'] as num?)?.toDouble(),
      location: json['location'],
    );
  }

  final String id;
  final String? imageUrl;
  final String? message;
  final DateTime? submittedAt;
  final dynamic verificationAnswers; // Can be JSON object or string
  final String? fenceStatus;
  final double? distFromCenter;
  final String? location;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'message': message,
      'submittedAt': submittedAt?.toIso8601String(),
      'verificationAnswers': verificationAnswers,
      'fenceStatus': fenceStatus,
      'distFromCenter': distFromCenter,
      'location': location,
    };
  }
}
