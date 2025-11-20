part of '../../../../../core/db/app_database.dart';

@DriftAccessor(tables: [Expenses])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.db);

  Future<List<Expense>> getAll() => select(expenses).get();
  Stream<List<Expense>> watchAll() => select(expenses).watch();

  Future<List<Expense>> getByRoomId(String roomId) =>
      (select(expenses)..where((t) => t.roomId.equals(roomId))).get();
  Stream<List<Expense>> watchByRoomId(String roomId) =>
      (select(expenses)..where((t) => t.roomId.equals(roomId))).watch();

  Future<Expense?> getById(String id) =>
      (select(expenses)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insert(ExpensesCompanion entry) => into(expenses).insert(entry);
  Future<bool> updateEntry(ExpensesCompanion entry) =>
      update(expenses).replace(entry);
  Future<int> deleteById(String id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Incomes])
class IncomesDao extends DatabaseAccessor<AppDatabase> with _$IncomesDaoMixin {
  IncomesDao(super.db);

  Future<List<Income>> getAll() => select(incomes).get();
  Stream<List<Income>> watchAll() => select(incomes).watch();

  Future<List<Income>> getByRoomId(String roomId) =>
      (select(incomes)..where((t) => t.roomId.equals(roomId))).get();
  Stream<List<Income>> watchByRoomId(String roomId) =>
      (select(incomes)..where((t) => t.roomId.equals(roomId))).watch();

  Future<Income?> getById(String id) =>
      (select(incomes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insert(IncomesCompanion entry) => into(incomes).insert(entry);
  Future<bool> updateEntry(IncomesCompanion entry) =>
      update(incomes).replace(entry);
  Future<int> deleteById(String id) =>
      (delete(incomes)..where((t) => t.id.equals(id))).go();
}
