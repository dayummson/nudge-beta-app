class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final DateTime? createdAt; // optional

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.phoneNumber,
    this.profilePhotoUrl,
    this.createdAt,
  });

  User copyWith({
    String? email,
    String? username,
    String? displayName,
    String? phoneNumber,
    String? profilePhotoUrl,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
