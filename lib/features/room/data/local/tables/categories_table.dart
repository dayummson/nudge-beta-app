import 'package:drift/drift.dart';
import 'type_converters.dart';

/// Drift table for categories
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()(); // primary key
  TextColumn get category => text().map(const CategoryJsonConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
