import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation_state.dart';

part 'participations_notifier.g.dart';

@Riverpod(keepAlive: true)
class ParticipationsNotifier extends _$ParticipationsNotifier {
  @override
  ParticipationsState build() {
    Future.microtask(fetchMyParticipations);
    return const ParticipationsState(isLoading: true);
  }

  // ── Vue joueur ────────────────────────────────────────────────

  Future<void> fetchMyParticipations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final participations = await ref
          .read(participationsRepositoryProvider)
          .getMyParticipations();
      state = state.copyWith(
        myParticipations: participations,
        isLoading: false,
      );
    } on AppException catch (e) {
      AppLogger.w('ParticipationsNotifier', 'fetchMyParticipations failed: $e');
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e, stackTrace) {
      AppLogger.e('ParticipationsNotifier', 'fetchMyParticipations failed', e,
          stackTrace);
      state = state.copyWith(error: 'Erreur inconnue', isLoading: false);
    }
  }

  Future<void> requestToJoin(String gameId, Game game) async {
    state = state.copyWith(isRequesting: true, clearError: true);
    try {
      final participation = await ref
          .read(participationsRepositoryProvider)
          .requestToJoin(gameId);
      final existingIndex =
          state.myParticipations.indexWhere((p) => p.gameId == gameId);
      final updatedList = List<Participation>.from(state.myParticipations);
      final withGame = Participation(
        id: participation.id,
        userId: participation.userId,
        gameId: participation.gameId,
        status: participation.status,
        createdAt: participation.createdAt,
        game: game,
      );
      if (existingIndex != -1) {
        updatedList[existingIndex] = withGame;
      } else {
        updatedList.add(withGame);
      }
      state = state.copyWith(
        myParticipations: updatedList,
        isRequesting: false,
      );
    } on AppException catch (e) {
      AppLogger.w('ParticipationsNotifier', 'requestToJoin failed: $e');
      state = state.copyWith(error: e.message, isRequesting: false);
    } catch (e, stackTrace) {
      AppLogger.e(
          'ParticipationsNotifier', 'requestToJoin failed', e, stackTrace);
      state = state.copyWith(error: 'Erreur inconnue', isRequesting: false);
    }
  }

  Future<void> cancelParticipation(String participationId) async {
    state = state.copyWith(isRequesting: true, clearError: true);
    try {
      final cancelled = await ref
          .read(participationsRepositoryProvider)
          .cancelParticipation(participationId);
      final existingIndex =
          state.myParticipations.indexWhere((p) => p.id == participationId);
      final updatedList = List<Participation>.from(state.myParticipations);
      updatedList[existingIndex] = state.myParticipations[existingIndex]
          .copyWith(status: cancelled.status);
      state = state.copyWith(
        myParticipations: updatedList,
        isRequesting: false,
      );
    } on AppException catch (e) {
      AppLogger.w('ParticipationsNotifier', 'cancelParticipation failed: $e');
      state = state.copyWith(error: e.message, isRequesting: false);
    } catch (e, stackTrace) {
      AppLogger.e('ParticipationsNotifier', 'cancelParticipation failed', e,
          stackTrace);
      state = state.copyWith(error: 'Erreur inconnue', isRequesting: false);
    }
  }

  Participation? getParticipationForGame(String gameId) {
    final matches = state.myParticipations.where((p) => p.gameId == gameId);
    return matches.isEmpty ? null : matches.first;
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ── Vue créateur ──────────────────────────────────────────────

  Future<void> fetchGameParticipations(String gameId) async {
    state = state.copyWith(
      loadingGameIds: {...state.loadingGameIds, gameId},
      clearGameRequestsError: true,
    );
    try {
      final participations = await ref
          .read(participationsRepositoryProvider)
          .getGameParticipations(gameId);
      final updated =
          Map<String, List<Participation>>.from(state.gameParticipations);
      updated[gameId] = participations;
      state = state.copyWith(
        gameParticipations: updated,
        loadingGameIds:
            state.loadingGameIds.where((id) => id != gameId).toSet(),
      );
    } on AppException catch (e) {
      AppLogger.w(
          'ParticipationsNotifier', 'fetchGameParticipations failed: $e');
      state = state.copyWith(
        gameRequestsError: e.message,
        loadingGameIds:
            state.loadingGameIds.where((id) => id != gameId).toSet(),
      );
    } catch (e, stackTrace) {
      AppLogger.e('ParticipationsNotifier', 'fetchGameParticipations failed',
          e, stackTrace);
      state = state.copyWith(
        gameRequestsError: 'Erreur inconnue',
        loadingGameIds:
            state.loadingGameIds.where((id) => id != gameId).toSet(),
      );
    }
  }

  Future<void> acceptParticipation(
      String participationId, String gameId) async {
    state = state.copyWith(
      processingIds: {...state.processingIds, participationId},
    );
    try {
      await ref
          .read(participationsRepositoryProvider)
          .acceptParticipation(participationId);

      final updated =
          Map<String, List<Participation>>.from(state.gameParticipations);
      updated[gameId] = (updated[gameId] ?? [])
          .map((p) => p.id == participationId
              ? p.copyWith(status: ParticipationStatus.ACCEPTED)
              : p)
          .toList();
      state = state.copyWith(
        gameParticipations: updated,
        processingIds:
            state.processingIds.where((id) => id != participationId).toSet(),
      );

      // currentPlayers a changé → on rafraîchit la liste des parties créées
      ref.read(gamesNotifierProvider.notifier).fetchCreatedGames();
    } on AppException catch (e) {
      AppLogger.w('ParticipationsNotifier', 'acceptParticipation failed: $e');
      state = state.copyWith(
        gameRequestsError: e.message,
        processingIds:
            state.processingIds.where((id) => id != participationId).toSet(),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
          'ParticipationsNotifier', 'acceptParticipation failed', e, stackTrace);
      state = state.copyWith(
        gameRequestsError: 'Erreur inconnue',
        processingIds:
            state.processingIds.where((id) => id != participationId).toSet(),
      );
    }
  }

  Future<void> rejectParticipation(
      String participationId, String gameId) async {
    state = state.copyWith(
      processingIds: {...state.processingIds, participationId},
    );
    try {
      await ref
          .read(participationsRepositoryProvider)
          .rejectParticipation(participationId);

      final updated =
          Map<String, List<Participation>>.from(state.gameParticipations);
      updated[gameId] = (updated[gameId] ?? [])
          .map((p) => p.id == participationId
              ? p.copyWith(status: ParticipationStatus.REJECTED)
              : p)
          .toList();
      state = state.copyWith(
        gameParticipations: updated,
        processingIds:
            state.processingIds.where((id) => id != participationId).toSet(),
      );
    } on AppException catch (e) {
      AppLogger.w('ParticipationsNotifier', 'rejectParticipation failed: $e');
      state = state.copyWith(
        gameRequestsError: e.message,
        processingIds:
            state.processingIds.where((id) => id != participationId).toSet(),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
          'ParticipationsNotifier', 'rejectParticipation failed', e, stackTrace);
      state = state.copyWith(
        gameRequestsError: 'Erreur inconnue',
        processingIds:
            state.processingIds.where((id) => id != participationId).toSet(),
      );
    }
  }
}
