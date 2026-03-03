import 'package:tcg_matchmaker/features/auth/entities/user_summary.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';

/// Entité métier Participation
class Participation {
  final String id;
  final String userId;
  final String gameId;
  final ParticipationStatus status;
  final DateTime? acceptedAt;
  final DateTime createdAt;
  /// Inclus quand on récupère "mes participations" mais pas quand on crée/modifie
  final Game? game;
  /// Inclus quand le créateur récupère les participations de sa partie
  final UserSummary? requester;

  const Participation({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.status,
    this.acceptedAt,
    required this.createdAt,
    this.game,
    this.requester,
  });

  bool get isPending => status == ParticipationStatus.PENDING;
  bool get isAccepted => status == ParticipationStatus.ACCEPTED;
  bool get isRejected => status == ParticipationStatus.REJECTED;
  bool get isCancelled => status == ParticipationStatus.CANCELLED;

  Participation copyWith({
    ParticipationStatus? status,
    DateTime? acceptedAt,
    Game? game,
    UserSummary? requester,
  }) {
    return Participation(
      id: id,
      userId: userId,
      gameId: gameId,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      createdAt: createdAt,
      game: game ?? this.game,
      requester: requester ?? this.requester,
    );
  }
}

/// Statut de participation (correspond au backend)
enum ParticipationStatus {
  PENDING,
  ACCEPTED,
  REJECTED,
  CANCELLED,
}

extension ParticipationStatusExtension on ParticipationStatus {
  String get label {
    switch (this) {
      case ParticipationStatus.PENDING:
        return 'En attente';
      case ParticipationStatus.ACCEPTED:
        return 'Acceptée';
      case ParticipationStatus.REJECTED:
        return 'Refusée';
      case ParticipationStatus.CANCELLED:
        return 'Annulée';
    }
  }
}
