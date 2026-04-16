import 'package:flutter/material.dart';
import 'package:tcg_matchmaker/core/theme/app_theme.dart';

enum GameType {
  POKEMON,
  YUGIOH,
  ONE_PIECE,
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
  String get label => switch (this) {
        GameType.ONE_PIECE => 'One Piece',
        GameType.POKEMON => 'Pokémon',
        GameType.YUGIOH => 'Yu-Gi-Oh!',
        GameType.NARUTO => 'Naruto',
      };

  String get shortLabel => switch (this) {
        GameType.ONE_PIECE => 'OP',
        GameType.POKEMON => 'PKM',
        GameType.YUGIOH => 'YGO',
        GameType.NARUTO => 'NRT',
      };

  Color get color => switch (this) {
        GameType.ONE_PIECE => const Color(0xFFE63946),
        GameType.POKEMON => const Color(0xFFFFCC00),
        GameType.YUGIOH => const Color(0xFFB8860B),
        GameType.NARUTO => const Color(0xFFFF6B35),
      };
}

extension GameStatusExtension on GameStatus {
  String get label => switch (this) {
        GameStatus.OPEN => 'Ouvert',
        GameStatus.FULL => 'Complet',
        GameStatus.IN_PROGRESS => 'En cours',
        GameStatus.FINISHED => 'Terminé',
        GameStatus.CANCELLED => 'Annulé',
      };

  Color get color => switch (this) {
        GameStatus.OPEN => AppTheme.statusOpen,
        GameStatus.FULL => AppTheme.statusFull,
        GameStatus.IN_PROGRESS => AppTheme.statusInProgress,
        GameStatus.FINISHED => AppTheme.statusFinished,
        GameStatus.CANCELLED => AppTheme.statusCancelled,
      };

  /// Couleur pour les marqueurs sur la map (bordure)
  /// OPEN = vert, CANCELLED = rouge, autres = blanc
  Color get markerColor => switch (this) {
        GameStatus.OPEN => AppTheme.statusOpen,
        GameStatus.CANCELLED => AppTheme.statusCancelled,
        GameStatus.FULL ||
        GameStatus.IN_PROGRESS ||
        GameStatus.FINISHED =>
          Colors.white,
      };

  bool get canJoin => this == GameStatus.OPEN;

  /// Texte du bouton quand on ne peut pas rejoindre
  String get disabledButtonText => switch (this) {
        GameStatus.OPEN => 'Rejoindre',
        GameStatus.FULL => 'Partie complète',
        GameStatus.CANCELLED => 'Partie annulée',
        GameStatus.IN_PROGRESS => 'Partie en cours',
        GameStatus.FINISHED => 'Partie terminée',
      };
}
