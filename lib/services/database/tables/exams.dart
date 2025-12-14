import 'package:drift/drift.dart';

class Exams extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get centerName => text()();
  TextColumn get centerCode => text()();
  TextColumn get jsonData => text()();
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
