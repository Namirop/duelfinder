import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'participations_provider.g.dart';

/// Provider pour les participations de l'utilisateur
/// TODO: Implémenter la logique de gestion des participations
@riverpod
class ParticipationsNotifier extends _$ParticipationsNotifier {
  @override
  AsyncValue<void> build() {
    // TODO: Charger les participations de l'utilisateur
    return const AsyncValue.data(null);
  }

  // TODO: Implémenter loadMyParticipations()
  // TODO: Implémenter joinGame(gameId)
  // TODO: Implémenter leaveGame(gameId)
  // TODO: Implémenter refresh()
}

/// Provider pour les participants d'une partie spécifique
@riverpod
class GameParticipantsNotifier extends _$GameParticipantsNotifier {
  @override
  AsyncValue<void> build(String gameId) {
    // TODO: Charger les participants de la partie
    return const AsyncValue.data(null);
  }

  // TODO: Implémenter refresh()
}
