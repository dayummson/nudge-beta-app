import 'package:drift/drift.dart';

class ExpenseUsers extends Table {
  TextColumn get expenseId => text()(); // foreign key to Expense
  TextColumn get userId => text()(); // foreign key to User
  TextColumn get status => text().map(const ExpenseStatusConverter())();

  @override
  Set<Column> get primaryKey => {expenseId, userId}; // composite key
}

enum ExpenseStatus { pending, paid, requested }

class ExpenseStatusConverter extends TypeConverter<ExpenseStatus, String> {
  const ExpenseStatusConverter();

  @override
  ExpenseStatus fromSql(String fromDb) {
    return ExpenseStatus.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => ExpenseStatus.pending,
    );
  }

  @override
  String toSql(ExpenseStatus value) => value.name;
}
