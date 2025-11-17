part of '../../../../../core/db/app_database.dart';

@DriftAccessor(tables: [Reactions])
class ReactionsDao extends DatabaseAccessor<AppDatabase>
    with _$ReactionsDaoMixin {
  ReactionsDao(super.db);

  Future<List<Reaction>> getAll() => select(reactions).get();
  Stream<List<Reaction>> watchAll() => select(reactions).watch();
  Future<Reaction?> getById(String id) =>
      (select(reactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insert(ReactionsCompanion entry) =>
      into(reactions).insert(entry);
  Future<bool> updateEntry(ReactionsCompanion entry) =>
      update(reactions).replace(entry);
  Future<int> deleteById(String id) =>
      (delete(reactions)..where((t) => t.id.equals(id))).go();
}
