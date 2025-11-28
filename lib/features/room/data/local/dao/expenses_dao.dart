part of '../../../../../core/db/app_database.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<List<Transaction>> getAll() => select(transactions).get();
  Stream<List<Transaction>> watchAll() => select(transactions).watch();

  Future<List<Transaction>> getByRoomId(String roomId) =>
      (select(transactions)..where((t) => t.roomId.equals(roomId))).get();
  Stream<List<Transaction>> watchByRoomId(String roomId) =>
      (select(transactions)..where((t) => t.roomId.equals(roomId))).watch();
  Future<Transaction?> getById(String id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insert(TransactionsCompanion entry) =>
      into(transactions).insert(entry);
  Future<bool> updateEntry(TransactionsCompanion entry) =>
      update(transactions).replace(entry);
  Future<int> deleteById(String id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  // Get transactions by type
  Future<List<Transaction>> getByType(String roomId, TransactionType type) =>
      (select(transactions)
            ..where((t) => t.roomId.equals(roomId))
            ..where((t) => t.type.equals(type.name)))
          .get();

  Stream<List<Transaction>> watchByType(String roomId, TransactionType type) =>
      (select(transactions)
            ..where((t) => t.roomId.equals(roomId))
            ..where((t) => t.type.equals(type.name)))
          .watch();
}
