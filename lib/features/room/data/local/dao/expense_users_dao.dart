part of '../../../../../core/db/app_database.dart';

@DriftAccessor(tables: [ExpenseUsers])
class ExpenseUsersDao extends DatabaseAccessor<AppDatabase>
    with _$ExpenseUsersDaoMixin {
  ExpenseUsersDao(super.db);

  Future<List<ExpenseUser>> getAll() => select(expenseUsers).get();
  Stream<List<ExpenseUser>> watchAll() => select(expenseUsers).watch();
  Future<List<ExpenseUser>> getByExpense(String expenseId) =>
      (select(expenseUsers)..where((t) => t.expenseId.equals(expenseId))).get();

  Future<void> upsert(ExpenseUsersCompanion entry) =>
      into(expenseUsers).insertOnConflictUpdate(entry);
  Future<int> deleteByIds(String expenseId, String userId) =>
      (delete(expenseUsers)..where(
            (t) => t.expenseId.equals(expenseId) & t.userId.equals(userId),
          ))
          .go();
}
