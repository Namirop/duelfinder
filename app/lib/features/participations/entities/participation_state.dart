import 'package:tcg_matchmaker/features/participations/entities/participation.dart';

class ParticipationsState {
  final List<Participation> myParticipations;
  final bool isLoading;
  final bool isRequesting; // Pour le bouton "Rejoindre"
  final String? error;

  /// Participations par partie (vue créateur) : gameId → liste
  final Map<String, List<Participation>> gameParticipations;

  /// IDs des participations en cours de traitement (accept/reject)
  final Set<String> processingIds;

  /// IDs des parties dont les participations sont en cours de chargement
  final Set<String> loadingGameIds;

  /// Erreur spécifique à la vue créateur (distincte de l'erreur "mes participations")
  final String? gameRequestsError;

  const ParticipationsState({
    this.myParticipations = const [],
    this.isLoading = false,
    this.isRequesting = false,
    this.error,
    this.gameParticipations = const {},
    this.processingIds = const {},
    this.loadingGameIds = const {},
    this.gameRequestsError,
  });

  // ── Vue joueur ────────────────────────────────────────────────
  List<Participation> get pendingParticipations =>
      myParticipations.where((p) => p.isPending).toList();

  List<Participation> get acceptedParticipations =>
      myParticipations.where((p) => p.isAccepted).toList();

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
      (gameParticipations[gameId] ?? [])
          .where((p) => p.isPending)
          .toList();

  List<Participation> getAcceptedForGame(String gameId) =>
      (gameParticipations[gameId] ?? [])
          .where((p) => p.isAccepted)
          .toList();

  bool isLoadingGame(String gameId) => loadingGameIds.contains(gameId);

  bool isProcessing(String id) => processingIds.contains(id);

  ParticipationsState copyWith({
    List<Participation>? myParticipations,
    bool? isLoading,
    bool? isRequesting,
    String? error,
    bool clearError = false,
    Map<String, List<Participation>>? gameParticipations,
    Set<String>? processingIds,
    Set<String>? loadingGameIds,
    String? gameRequestsError,
    bool clearGameRequestsError = false,
  }) {
    return ParticipationsState(
      myParticipations: myParticipations ?? this.myParticipations,
      isLoading: isLoading ?? this.isLoading,
      isRequesting: isRequesting ?? this.isRequesting,
      error: clearError ? null : (error ?? this.error),
      gameParticipations: gameParticipations ?? this.gameParticipations,
      processingIds: processingIds ?? this.processingIds,
      loadingGameIds: loadingGameIds ?? this.loadingGameIds,
      gameRequestsError: clearGameRequestsError
          ? null
          : (gameRequestsError ?? this.gameRequestsError),
    );
  }
}
