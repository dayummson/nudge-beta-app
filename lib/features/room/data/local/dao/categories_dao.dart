part of '../../../../../core/db/app_database.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Future<List<CategoryRow>> getAll() => select(categories).get();
  Stream<List<CategoryRow>> watchAll() => select(categories).watch();
  Future<CategoryRow?> getById(String id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(CategoriesCompanion entry) =>
      into(categories).insertOnConflictUpdate(entry);
  Future<int> deleteById(String id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();
}
