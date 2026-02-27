import 'package:tcg_matchmaker/features/auth/entities/user_summary.dart';

class UserSummaryModel {
  final String id;
  final String username;
  final String avatar;

  const UserSummaryModel({
    required this.id,
    required this.username,
    required this.avatar,
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      id: json['id'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String,
    );
  }

  UserSummary toEntity() {
    return UserSummary(
      id: id,
      username: username,
      avatar: avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
    };
  }
}
