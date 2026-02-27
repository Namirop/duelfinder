import 'package:tcg_matchmaker/features/auth/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String avatar;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.avatar,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      avatar: avatar,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
