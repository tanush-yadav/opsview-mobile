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
