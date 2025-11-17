import 'package:drift/drift.dart';

class RoomMembers extends Table {
  TextColumn get roomId => text()(); // foreign key to Room
  TextColumn get userId => text()(); // foreign key to User
  TextColumn get role => text().map(const RoomRoleConverter())();
  TextColumn get status => text().map(const RoomStatusConverter())();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {roomId, userId}; // composite key
}

enum RoomRole { owner, admin, member }

enum RoomStatus { active, invited, pending }

class RoomRoleConverter extends TypeConverter<RoomRole, String> {
  const RoomRoleConverter();

  @override
  RoomRole fromSql(String fromDb) {
    return RoomRole.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => RoomRole.member,
    );
  }

  @override
  String toSql(RoomRole value) => value.name;
}

class RoomStatusConverter extends TypeConverter<RoomStatus, String> {
  const RoomStatusConverter();

  @override
  RoomStatus fromSql(String fromDb) {
    return RoomStatus.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => RoomStatus.pending,
    );
  }

  @override
  String toSql(RoomStatus value) => value.name;
}
