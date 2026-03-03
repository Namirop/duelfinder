import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/games/entities/game_requests_state.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation.dart';

part 'game_requests_notifier.g.dart';

@riverpod
class GameRequestsNotifier extends _$GameRequestsNotifier {
  @override
  GameRequestsState build(String gameId) {
    Future.microtask(_fetchRequests);
    return const GameRequestsState(isLoading: true);
  }

  Future<void> refresh() => _fetchRequests();

  Future<void> _fetchRequests() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final participations = await ref
          .read(participationsRepositoryProvider)
          .getGameParticipations(gameId);
      state = state.copyWith(participations: participations, isLoading: false);
    } on AppException catch (e) {
      AppLogger.w('GameRequestsNotifier', 'fetchRequests failed: $e');
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e, stackTrace) {
      AppLogger.e('GameRequestsNotifier', 'fetchRequests failed', e, stackTrace);
      state = state.copyWith(error: 'Erreur inconnue', isLoading: false);
    }
  }

  Future<void> accept(String participationId) async {
    state = state.copyWith(
      processingIds: {...state.processingIds, participationId},
    );
    try {
      await ref
          .read(participationsRepositoryProvider)
          .acceptParticipation(participationId);

      state = state.copyWith(
        participations: state.participations
            .map((p) => p.id == participationId
                ? p.copyWith(status: ParticipationStatus.ACCEPTED)
                : p)
            .toList(),
        processingIds: state.processingIds
            .where((id) => id != participationId)
            .toSet(),
      );

      // Le nombre de joueurs a changé → on rafraîchit la liste des parties du créateur
      ref.read(gamesNotifierProvider.notifier).fetchCreatedGames();
    } on AppException catch (e) {
      AppLogger.w('GameRequestsNotifier', 'accept failed: $e');
      state = state.copyWith(
        error: e.message,
        processingIds: state.processingIds
            .where((id) => id != participationId)
            .toSet(),
      );
    } catch (e, stackTrace) {
      AppLogger.e('GameRequestsNotifier', 'accept failed', e, stackTrace);
      state = state.copyWith(
        error: 'Erreur inconnue',
        processingIds: state.processingIds
            .where((id) => id != participationId)
            .toSet(),
      );
    }
  }

  Future<void> reject(String participationId) async {
    state = state.copyWith(
      processingIds: {...state.processingIds, participationId},
    );
    try {
      await ref
          .read(participationsRepositoryProvider)
          .rejectParticipation(participationId);

      state = state.copyWith(
        participations: state.participations
            .map((p) => p.id == participationId
                ? p.copyWith(status: ParticipationStatus.REJECTED)
                : p)
            .toList(),
        processingIds: state.processingIds
            .where((id) => id != participationId)
            .toSet(),
      );
    } on AppException catch (e) {
      AppLogger.w('GameRequestsNotifier', 'reject failed: $e');
      state = state.copyWith(
        error: e.message,
        processingIds: state.processingIds
            .where((id) => id != participationId)
            .toSet(),
      );
    } catch (e, stackTrace) {
      AppLogger.e('GameRequestsNotifier', 'reject failed', e, stackTrace);
      state = state.copyWith(
        error: 'Erreur inconnue',
        processingIds: state.processingIds
            .where((id) => id != participationId)
            .toSet(),
      );
    }
  }
}
