import 'package:drift/drift.dart';

class TaskImages extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get localPath => text()();
  TextColumn get message => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get capturedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
