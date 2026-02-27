import 'package:tcg_matchmaker/features/auth/models/user_summary_model.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';

class GameModel {
  final String id;
  final GameType gameType;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime scheduledAt;
  final int duration;
  final int maxPlayers;
  final GameStatus status;
  final UserSummaryModel creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GameModel({
    required this.id,
    required this.gameType,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.scheduledAt,
    required this.duration,
    required this.maxPlayers,
    required this.status,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      gameType: GameType.values.firstWhere(
        (e) => e.name == json['gameType'],
        orElse: () => GameType.POKEMON,
      ),
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      duration: json['duration'] as int,
      maxPlayers: json['maxPlayers'] as int,
      status: GameStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GameStatus.OPEN,
      ),
      creator:
          UserSummaryModel.fromJson(json['creator'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Game toEntity() {
    return Game(
      id: id,
      gameType: gameType,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      scheduledAt: scheduledAt,
      duration: duration,
      maxPlayers: maxPlayers,
      status: status,
      creator: creator.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameType': gameType.name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledAt': scheduledAt.toIso8601String(),
      'duration': duration,
      'maxPlayers': maxPlayers,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
