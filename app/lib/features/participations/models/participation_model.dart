import 'package:tcg_matchmaker/features/auth/entities/user_summary.dart';
import 'package:tcg_matchmaker/features/games/models/game_model.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation.dart';

class ParticipationModel {
  final String id;
  final String userId;
  final String gameId;
  final ParticipationStatus status;
  final DateTime? acceptedAt;
  final DateTime createdAt;
  final GameModel? game;
  final UserSummary? requester;

  const ParticipationModel({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.status,
    this.acceptedAt,
    required this.createdAt,
    this.game,
    this.requester,
  });

  factory ParticipationModel.fromJson(Map<String, dynamic> json) {
    UserSummary? requester;
    if (json['user'] != null) {
      final u = json['user'] as Map<String, dynamic>;
      requester = UserSummary(
        id: u['id'] as String,
        username: u['username'] as String,
        avatar: u['avatar'] as String,
      );
    }

    return ParticipationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      gameId: json['gameId'] as String,
      status: ParticipationStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      game: json['game'] != null
          ? GameModel.fromJson(json['game'] as Map<String, dynamic>)
          : null,
      requester: requester,
    );
  }

  Participation toEntity() {
    return Participation(
      id: id,
      userId: userId,
      gameId: gameId,
      status: status,
      acceptedAt: acceptedAt,
      createdAt: createdAt,
      game: game?.toEntity(),
      requester: requester,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'gameId': gameId,
      'status': status.name,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
