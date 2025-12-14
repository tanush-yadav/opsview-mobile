import 'package:drift/drift.dart';

class Sessions extends Table {
  TextColumn get accessToken => text()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  TextColumn get examId => text().nullable()();
  TextColumn get centerId => text().nullable()();
  TextColumn get examCode => text().nullable()();
  TextColumn get centerCode => text().nullable()();
  TextColumn get centerName => text().nullable()();
  TextColumn get examName => text().nullable()();
  TextColumn get userDataJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}
