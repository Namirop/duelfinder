/// DTO pour la requête d'inscription
class RegisterRequestDto {
  final String email;
  final String password;
  final String username;

  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
    };
  }
}
