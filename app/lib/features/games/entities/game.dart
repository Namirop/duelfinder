import 'package:flutter/material.dart';
import 'package:tcg_matchmaker/core/theme/app_theme.dart';
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
  final GameStatus effectiveStatus;
  final int currentPlayers;
  final UserSummary creator;
  final List<UserSummary> participants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance;

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
    required this.effectiveStatus,
    required this.currentPlayers,
    required this.creator,
    this.participants = const [],
    required this.createdAt,
    required this.updatedAt,
    this.distance,
  });

  bool get isFull => currentPlayers >= maxPlayers;
  bool get hasAvailableSpots => currentPlayers < maxPlayers;
  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());
  bool get isOpen => effectiveStatus == GameStatus.OPEN;

  /// Heure de fin calculée (scheduledAt + duration)
  DateTime get endTime => scheduledAt.add(Duration(minutes: duration));

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
    GameStatus? effectiveStatus,
    int? currentPlayers,
    UserSummary? creator,
    List<UserSummary>? participants,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
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
      effectiveStatus: effectiveStatus ?? this.effectiveStatus,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      creator: creator ?? this.creator,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
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
  FINISHED,
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
      case GameStatus.FINISHED:
        return 'Terminé';
      case GameStatus.CANCELLED:
        return 'Annulé';
    }
  }

  Color get color {
    switch (this) {
      case GameStatus.OPEN:
        return AppTheme.statusOpen;
      case GameStatus.FULL:
        return AppTheme.statusFull;
      case GameStatus.IN_PROGRESS:
        return AppTheme.statusInProgress;
      case GameStatus.FINISHED:
        return AppTheme.statusFinished;
      case GameStatus.CANCELLED:
        return AppTheme.statusCancelled;
    }
  }

  /// Couleur pour les marqueurs sur la map (bordure)
  /// OPEN = vert, CANCELLED = rouge, autres = blanc
  Color get markerColor {
    switch (this) {
      case GameStatus.OPEN:
        return AppTheme.statusOpen;
      case GameStatus.CANCELLED:
        return AppTheme.statusCancelled;
      case GameStatus.FULL:
      case GameStatus.IN_PROGRESS:
      case GameStatus.FINISHED:
        return Colors.white;
    }
  }

  /// Retourne true si la partie est visible (vert = en attente de joueurs)
  bool get isOpen => this == GameStatus.OPEN;

  /// Retourne true si la partie est "blanche" (complète, en cours ou terminée)
  bool get isWhite =>
      this == GameStatus.FULL ||
      this == GameStatus.IN_PROGRESS ||
      this == GameStatus.FINISHED;

  /// Retourne true si la partie est annulée (rouge)
  bool get isCancelled => this == GameStatus.CANCELLED;

  /// Peut-on demander à rejoindre cette partie ?
  bool get canJoin => this == GameStatus.OPEN || this == GameStatus.FULL;

  /// Texte du bouton quand on ne peut pas rejoindre
  String get disabledButtonText {
    switch (this) {
      case GameStatus.OPEN:
        return 'Rejoindre'; // Ne devrait pas arriver
      case GameStatus.FULL:
        return 'Partie complète';
      case GameStatus.CANCELLED:
        return 'Partie annulée';
      case GameStatus.IN_PROGRESS:
        return 'Partie en cours';
      case GameStatus.FINISHED:
        return 'Partie terminée';
    }
  }
}
