import 'package:drift/drift.dart';
import 'type_converters.dart';

/// Unified Drift table for Transactions (replaces separate Expenses and Incomes tables)
class Transactions extends Table {
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
  TextColumn get type =>
      text().map(const TransactionTypeConverter())(); // expense or income
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))(); // offline-first flag
  DateTimeColumn get lastUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)(); // fixed type

  @override
  Set<Column> get primaryKey => {id};
}
