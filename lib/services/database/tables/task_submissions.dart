import 'package:drift/drift.dart';

class TaskSubmissions extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get observations => text().nullable()();
  TextColumn get verificationAnswers => text()(); // JSON string
  TextColumn get imagePaths => text()(); // JSON array: [{path, timestamp}, ...]
  TextColumn get status => text().withDefault(const Constant('UNSYNCED'))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get submittedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
