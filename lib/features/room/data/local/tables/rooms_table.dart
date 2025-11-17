import 'package:drift/drift.dart';

/// Converter for List<&ltString> <-> CSV string
class UsersConverter extends TypeConverter<List<String>, String> {
  const UsersConverter();

  @override
  List<String> fromSql(String? fromDb) {
    if (fromDb == null || fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  @override
  String toSql(List<String>? value) {
    if (value == null || value.isEmpty) return '';
    return value.join(',');
  }
}

/// Drift table for Room
class Rooms extends Table {
  TextColumn get id => text()(); // Primary key: string ID
  TextColumn get name => text()();
  TextColumn get ownerId => text()();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  TextColumn get users =>
      text().map(const UsersConverter())(); // JSON / CSV encoded
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get showIncome => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
