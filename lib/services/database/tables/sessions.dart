import 'package:drift/drift.dart';

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get service => text().nullable()();
  TextColumn get userJson => text().nullable()();
  TextColumn get examJson => text().nullable()();
  TextColumn get centerJson => text().nullable()();
  TextColumn get onboardingStep => text().withDefault(const Constant('confirmation'))();
  TextColumn get selectedShiftId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
