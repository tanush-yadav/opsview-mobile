import 'package:drift/drift.dart';

class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contact => text()();
  TextColumn get aadhaar => text()();
  TextColumn get selfieLocalPath => text().nullable()();
  TextColumn get mobileVerificationId => text().nullable()();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
