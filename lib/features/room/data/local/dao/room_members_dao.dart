part of '../../../../../core/db/app_database.dart';

@DriftAccessor(tables: [RoomMembers])
class RoomMembersDao extends DatabaseAccessor<AppDatabase>
    with _$RoomMembersDaoMixin {
  RoomMembersDao(super.db);

  Future<List<RoomMember>> getAll() => select(roomMembers).get();
  Stream<List<RoomMember>> watchAll() => select(roomMembers).watch();
  Future<List<RoomMember>> getByRoom(String roomId) =>
      (select(roomMembers)..where((t) => t.roomId.equals(roomId))).get();

  Future<void> upsert(RoomMembersCompanion entry) =>
      into(roomMembers).insertOnConflictUpdate(entry);
  Future<int> deleteByIds(String roomId, String userId) => (delete(
    roomMembers,
  )..where((t) => t.roomId.equals(roomId) & t.userId.equals(userId))).go();
}
