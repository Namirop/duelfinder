/// Entité partielle pour affichage (listes, cartes, etc.)
class UserSummary {
  final String id;
  final String username;
  final String avatar;

  const UserSummary({
    required this.id,
    required this.username,
    required this.avatar,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSummary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
