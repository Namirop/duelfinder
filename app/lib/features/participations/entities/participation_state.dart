import 'package:tcg_matchmaker/features/participations/entities/participation.dart';

class ParticipationsState {
  final List<Participation> myParticipations;
  final bool isLoadingMyParticipations;
  final bool isRequesting;
  final String? error;

  /// Participations par partie (vue créateur) : gameId → liste
  final Map<String, List<Participation>> gameParticipants;

  /// IDs des participations en cours de traitement (accept/reject)
  /// => utile pour afficher le loader spécifiquement à ce participants.
  final Set<String> processingIds;
  final bool isLoadingGameParticipants;
  final String? getGameParticipantsError;

  const ParticipationsState({
    this.myParticipations = const [],
    this.isLoadingMyParticipations = false,
    this.isRequesting = false,
    this.error,
    this.gameParticipants = const {},
    this.processingIds = const {},
    this.isLoadingGameParticipants = false,
    this.getGameParticipantsError,
  });

  // ── Vue joueur ────────────────────────────────────────────────
  /// PENDING/ACCEPTED toujours visibles ; CANCELLED/REJECTED uniquement aujourd'hui
  List<Participation> get visibleParticipations {
    final today = DateTime.now();
    return myParticipations.where((p) {
      if (p.isPending || p.isAccepted) return true;
      return p.createdAt.year == today.year &&
          p.createdAt.month == today.month &&
          p.createdAt.day == today.day;
    }).toList();
  }

  // ── Vue créateur ──────────────────────────────────────────────
  List<Participation> getPendingForGame(String gameId) =>
      (gameParticipants[gameId] ?? []).where((p) => p.isPending).toList();

  List<Participation> getAcceptedForGame(String gameId) =>
      (gameParticipants[gameId] ?? []).where((p) => p.isAccepted).toList();

  bool isProcessing(String id) => processingIds.contains(id);

  ParticipationsState copyWith({
    List<Participation>? myParticipations,
    bool? isLoadingMyParticipations,
    bool? isRequesting,
    String? error,
    bool clearError = false,
    Map<String, List<Participation>>? gameParticipants,
    Set<String>? processingIds,
    bool? isLoadingGameParticipants,
    String? getGameParticipantsError,
    bool clearGetGameParticipantsError = false,
  }) {
    return ParticipationsState(
      myParticipations: myParticipations ?? this.myParticipations,
      isLoadingMyParticipations:
          isLoadingMyParticipations ?? this.isLoadingMyParticipations,
      isRequesting: isRequesting ?? this.isRequesting,
      error: clearError
          ? null
          : (error ?? this.error),
      gameParticipants: gameParticipants ?? this.gameParticipants,
      processingIds: processingIds ?? this.processingIds,
      isLoadingGameParticipants:
          isLoadingGameParticipants ?? this.isLoadingGameParticipants,
      getGameParticipantsError: clearGetGameParticipantsError
          ? null
          : (getGameParticipantsError ?? this.getGameParticipantsError),
    );
  }
}
