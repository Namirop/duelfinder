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
  final GameStatus effectiveStatus;
  final int currentPlayers;
  final UserSummaryModel creator;
  final List<UserSummaryModel> participants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance;
  final int pendingCount;

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
    required this.effectiveStatus,
    required this.currentPlayers,
    required this.creator,
    this.participants = const [],
    required this.createdAt,
    required this.updatedAt,
    this.distance,
    this.pendingCount = 0,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    // Le backend renvoie effectiveStatus (calculé) et status (stocké en base)
    // Pas de fallback : si le backend envoie une valeur invalide, on veut le savoir
    final storedStatus = GameStatus.values.firstWhere(
      (e) => e.name == json['status'],
    );
    final effectiveStatus = GameStatus.values.firstWhere(
      (e) => e.name == json['effectiveStatus'],
      orElse: () =>
          storedStatus, // Fallback sur status si effectiveStatus absent
    );

    return GameModel(
      id: json['id'] as String,
      gameType: GameType.values.firstWhere(
        (e) => e.name == json['gameType'],
      ),
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String).toLocal(),
      duration: json['duration'] as int,
      maxPlayers: json['maxPlayers'] as int,
      status: storedStatus,
      effectiveStatus: effectiveStatus,
      currentPlayers: json['currentPlayers'] as int? ?? 1,
      creator:
          UserSummaryModel.fromJson(json['creator'] as Map<String, dynamic>),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => UserSummaryModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      pendingCount: json['pendingCount'] as int? ?? 0,
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
      effectiveStatus: effectiveStatus,
      currentPlayers: currentPlayers,
      creator: creator.toEntity(),
      participants: participants.map((p) => p.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      distance: distance,
      pendingCount: pendingCount,
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
      'effectiveStatus': effectiveStatus.name,
      'currentPlayers': currentPlayers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (distance != null) 'distance': distance,
    };
  }
}
