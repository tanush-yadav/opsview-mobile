import 'package:drift/drift.dart';

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get clientCode => text()();
  TextColumn get examId => text()();
  TextColumn get centerId => text()();
  TextColumn get shiftId => text()();
  TextColumn get service => text()();
  IntColumn get seqNumber => integer().withDefault(const Constant(0))();
  BoolColumn get required => boolean().withDefault(const Constant(true))();
  TextColumn get taskId => text()();
  TextColumn get taskLabel => text()();
  TextColumn get taskDesc => text().nullable()();
  TextColumn get taskType => text().withDefault(const Constant('IMAGE'))();
  TextColumn get taskStatus => text().withDefault(const Constant('PENDING'))();
  TextColumn get centerCode => text()();
  TextColumn get centerName => text()();
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
