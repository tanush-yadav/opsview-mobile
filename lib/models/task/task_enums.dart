enum TaskStatus {
  pending,
  submitted;

  String get toDbValue => name.toUpperCase();
  String get toUIValue => name.toLowerCase();
}

enum SyncStatus {
  synced,
  unsynced;

  String get toDbValue => name.toUpperCase();
  String get toUIValue => name.toLowerCase();
}

enum TaskType {
  image,
  checklist;

  String get toDbValue => name.toUpperCase();

  static TaskType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'IMAGE':
        return TaskType.image;
      case 'CHECKLIST':
        return TaskType.checklist;
      default:
        return null;
    }
  }
}
