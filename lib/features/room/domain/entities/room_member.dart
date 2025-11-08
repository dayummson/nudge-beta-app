class RoomMember {
  final String id;
  final String role;
  final String status;
  final DateTime joinedAt;

  const RoomMember({
    required this.id,
    required this.role,
    required this.status,
    required this.joinedAt,
  });
}
