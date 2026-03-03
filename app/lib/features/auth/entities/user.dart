/// Entité métier User - objet pur sans sérialisation
class User {
  final String id;
  final String email;
  final String username;
  final String? bio;
  final String avatar;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.bio,
    required this.avatar,
    this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? bio,
    String? avatar,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
