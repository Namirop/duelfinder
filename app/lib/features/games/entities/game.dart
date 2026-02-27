import 'package:tcg_matchmaker/features/auth/entities/user_summary.dart';

class Game {
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
  final UserSummary creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Game({
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

  bool get isFull => false; // TODO: implémenter avec participations
  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());
  bool get isOpen => status == GameStatus.OPEN;

  Game copyWith({
    String? id,
    GameType? gameType,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? scheduledAt,
    int? duration,
    int? maxPlayers,
    GameStatus? status,
    UserSummary? creator,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Game(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      duration: duration ?? this.duration,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      status: status ?? this.status,
      creator: creator ?? this.creator,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Game && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum GameType {
  ONE_PIECE,
  POKEMON,
  YUGIOH,
  NARUTO,
}

enum GameStatus {
  OPEN,
  FULL,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED,
}

extension GameTypeExtension on GameType {
  String get label {
    switch (this) {
      case GameType.ONE_PIECE:
        return 'One Piece';
      case GameType.POKEMON:
        return 'Pokémon';
      case GameType.YUGIOH:
        return 'Yu-Gi-Oh!';
      case GameType.NARUTO:
        return 'Naruto';
    }
  }
}

extension GameStatusExtension on GameStatus {
  String get label {
    switch (this) {
      case GameStatus.OPEN:
        return 'Ouvert';
      case GameStatus.FULL:
        return 'Complet';
      case GameStatus.IN_PROGRESS:
        return 'En cours';
      case GameStatus.COMPLETED:
        return 'Terminé';
      case GameStatus.CANCELLED:
        return 'Annulé';
    }
  }
}
