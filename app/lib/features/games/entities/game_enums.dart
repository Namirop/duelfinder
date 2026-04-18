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

  bool get canJoin => this == GameStatus.OPEN;

  /// Texte du bouton quand on ne peut pas rejoindre
  String get disabledButtonText => switch (this) {
        GameStatus.FULL => 'Partie complète',
        GameStatus.CANCELLED => 'Partie annulée',
        GameStatus.IN_PROGRESS => 'Partie en cours',
        GameStatus.FINISHED => 'Partie terminée',
        GameStatus.OPEN => '', // jamais appelé (canJoin = true)
      };
}
