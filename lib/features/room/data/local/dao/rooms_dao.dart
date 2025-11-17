part of '../../../../../core/db/app_database.dart';

@DriftAccessor(tables: [Rooms])
class RoomsDao extends DatabaseAccessor<AppDatabase> with _$RoomsDaoMixin {
  RoomsDao(super.db);

  Future<List<Room>> getAllRooms() => select(rooms).get();
  Stream<List<Room>> watchAllRooms() => select(rooms).watch();
  Future<Room?> getRoomById(String id) =>
      (select(rooms)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertRoom(RoomsCompanion entry) => into(rooms).insert(entry);
  Future<bool> updateRoom(RoomsCompanion entry) => update(rooms).replace(entry);
  Future<int> deleteRoomById(String id) =>
      (delete(rooms)..where((t) => t.id.equals(id))).go();
}
