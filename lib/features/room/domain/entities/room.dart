class Room {
  final String id;
  final String name;
  final String ownerId;
  final bool isShared;
  final List<String> users;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool showIncome;

  const Room({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.isShared,
    required this.users,
    required this.showIncome,
    required this.createdAt,
    required this.updatedAt,
  });
}
