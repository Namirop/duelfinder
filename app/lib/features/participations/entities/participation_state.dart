import 'package:tcg_matchmaker/features/participations/entities/participation.dart';

class ParticipationsState {
  final List<Participation> myParticipations;
  final bool isLoading;
  final bool isRequesting; // Pour le bouton "Rejoindre"
  final String? error;

  const ParticipationsState({
    this.myParticipations = const [],
    this.isLoading = false,
    this.isRequesting = false,
    this.error,
  });

  /// Participations en attente (demandes envoyées)
  List<Participation> get pendingParticipations =>
      myParticipations.where((p) => p.isPending).toList();

  /// Participations acceptées (parties confirmées)
  List<Participation> get acceptedParticipations =>
      myParticipations.where((p) => p.isAccepted).toList();

  /// Participations visibles dans l'onglet :
  /// - PENDING et ACCEPTED : toujours affichées
  /// - CANCELLED et REJECTED : uniquement si créées aujourd'hui
  List<Participation> get visibleParticipations {
    final today = DateTime.now();
    return myParticipations.where((p) {
      if (p.isPending || p.isAccepted) return true;
      return p.createdAt.year == today.year &&
          p.createdAt.month == today.month &&
          p.createdAt.day == today.day;
    }).toList();
  }

  ParticipationsState copyWith({
    List<Participation>? myParticipations,
    bool? isLoading,
    bool? isRequesting,
    String? error,
    bool clearError = false,
  }) {
    return ParticipationsState(
      myParticipations: myParticipations ?? this.myParticipations,
      isLoading: isLoading ?? this.isLoading,
      isRequesting: isRequesting ?? this.isRequesting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
