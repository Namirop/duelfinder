import 'package:flutter/material.dart';
import 'package:tcg_matchmaker/core/theme/app_theme.dart';

enum ParticipationStatus {
  PENDING,
  ACCEPTED,
  REJECTED,
  CANCELLED,
}

extension ParticipationStatusExtension on ParticipationStatus {
  String get label => switch (this) {
        ParticipationStatus.PENDING => 'En attente',
        ParticipationStatus.ACCEPTED => 'Acceptée',
        ParticipationStatus.REJECTED => 'Refusée',
        ParticipationStatus.CANCELLED => 'Annulée',
      };

  Color get color => switch (this) {
        ParticipationStatus.PENDING => AppTheme.statusFull,
        ParticipationStatus.ACCEPTED => AppTheme.statusOpen,
        ParticipationStatus.REJECTED => AppTheme.statusCancelled,
        ParticipationStatus.CANCELLED => AppTheme.statusFinished,
      };

  IconData get icon => switch (this) {
        ParticipationStatus.PENDING => Icons.hourglass_top_rounded,
        ParticipationStatus.ACCEPTED => Icons.check_circle_rounded,
        ParticipationStatus.REJECTED => Icons.cancel_rounded,
        ParticipationStatus.CANCELLED => Icons.remove_circle_rounded,
      };
}
