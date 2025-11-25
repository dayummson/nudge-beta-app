import 'package:drift/drift.dart';
import 'type_converters.dart';

/// Drift table for Expenses
class Expenses extends Table {
  TextColumn get id => text()(); // primary key
  TextColumn get roomId => text()(); // room association
  TextColumn get description => text()();
  TextColumn get category =>
      text().map(const CategoryJsonConverter())(); // store as JSON
  RealColumn get amount => real()();
  TextColumn get location =>
      text().map(const LocationJsonConverter()).nullable()();
  TextColumn get hashtags => text().map(HashtagsJsonConverter())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift table for Incomes (same structure as Expense)
class Incomes extends Table {
  TextColumn get id => text()();
  TextColumn get roomId => text()(); // room association
  TextColumn get description => text()();
  TextColumn get category =>
      text().map(const CategoryJsonConverter())(); // store as JSON
  RealColumn get amount => real()();
  TextColumn get location =>
      text().map(const LocationJsonConverter()).nullable()();
  TextColumn get hashtags => text().map(HashtagsJsonConverter())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
