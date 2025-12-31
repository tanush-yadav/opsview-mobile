import 'package:drift/drift.dart';

class Profiles extends Table {
  // Local UUID - primary key
  TextColumn get id => text()();

  // Foreign key to shift
  TextColumn get shiftId => text()();

  // Profile details
  TextColumn get name => text()();
  TextColumn get contact => text()();
  IntColumn get age => integer()();
  TextColumn get aadhaar => text()();

  // Selfie & liveness
  TextColumn get selfieLocalPath => text().nullable()();
  TextColumn get livenessStatus => text().withDefault(const Constant('PENDING'))(); // PENDING, PASSED, FAILED
  RealColumn get livenessScore => real().nullable()();
  DateTimeColumn get livenessAttemptedAt => dateTime().nullable()();

  // Location
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get location => text().nullable()();

  // Mobile verification - if mobileVerificationId is not null, mobile is verified
  TextColumn get mobileVerificationId => text().nullable()();

  // Backend sync - if backendProfileId is not null, profile is synced
  TextColumn get backendProfileId => text().nullable()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
