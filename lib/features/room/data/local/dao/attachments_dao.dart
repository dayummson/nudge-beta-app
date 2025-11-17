part of '../../../../../core/db/app_database.dart';

@DriftAccessor(tables: [Attachments])
class AttachmentsDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentsDaoMixin {
  AttachmentsDao(super.db);

  Future<List<Attachment>> getAll() => select(attachments).get();
  Stream<List<Attachment>> watchAll() => select(attachments).watch();
  Future<Attachment?> getById(String id) =>
      (select(attachments)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insert(AttachmentsCompanion entry) =>
      into(attachments).insert(entry);
  Future<bool> updateEntry(AttachmentsCompanion entry) =>
      update(attachments).replace(entry);
  Future<int> deleteById(String id) =>
      (delete(attachments)..where((t) => t.id.equals(id))).go();
}
