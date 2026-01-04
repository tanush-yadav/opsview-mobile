/// Checklist item for task verification
class ChecklistItem {
  ChecklistItem({
    required this.id,
    required this.question,
    required this.required,
    required this.value,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      required: json['required'] ?? false,
      value: json['value'] ?? 'NA',
    );
  }

  final String id;
  final String question;
  final bool required;
  final String value;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'required': required,
      'value': value,
    };
  }

  /// Create a copy with updated value
  ChecklistItem copyWith({String? value}) {
    return ChecklistItem(
      id: id,
      question: question,
      required: required,
      value: value ?? this.value,
    );
  }
}
