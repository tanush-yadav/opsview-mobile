import 'package:drift/drift.dart';

class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get examId => text()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isSelected => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
