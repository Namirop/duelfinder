import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/entities/game_state.dart';
import 'package:tcg_matchmaker/features/games/models/create_game_model.dart';

part 'games_provider.g.dart';

@riverpod
class GamesNotifier extends _$GamesNotifier {
  @override
  GamesState build() {
    Future.microtask(() => fetchExistingGames());
    return const GamesState(isLoadingExisting: true);
  }

  Future<void> fetchExistingGames() async {
    state = state.copyWith(isLoadingExisting: true, clearErrorExisting: true);
    try {
      final position = await ref.read(currentPositionProvider.future);
      if (position == null) {
        state = state.copyWith(
          errorExisting: 'Position non disponible',
          isLoadingExisting: false,
        );
        return;
      }
      double lat = position.latitude;
      double lng = position.longitude;

      final games = await ref.read(gamesRepositoryProvider).fetchExistingGames(
            latitude: lat,
            longitude: lng,
            distance: state.distanceFilter,
            hours: state.scheduleFilter,
            gameType: state.gameTypeFilter?.name,
          );
      state = state.copyWith(
        existingGames: games,
        isLoadingExisting: false,
      );
    } on AppException catch (e) {
      AppLogger.w(
          'GamesNotifier', 'fetchExistingGames failed: ${e.toString()}');
      state =
          state.copyWith(errorExisting: e.message, isLoadingExisting: false);
    } catch (e, stackTrace) {
      AppLogger.e('GamesNotifier', 'fetchExistingGames failed', e, stackTrace);
      state = state.copyWith(
          errorExisting: 'Erreur inconnue', isLoadingExisting: false);
    }
  }

  Future<void> fetchCreatedGames() async {
    state = state.copyWith(isLoadingMyGames: true, clearErrorMyGames: true);
    try {
      final games = await ref.read(gamesRepositoryProvider).fetchCreatedGames();
      state = state.copyWith(
        myGames: games,
        isLoadingMyGames: false,
      );
    } on AppException catch (e) {
      AppLogger.w('GamesNotifier', 'fetchCreatedGames failed: ${e.toString()}');
      state = state.copyWith(errorMyGames: e.message, isLoadingMyGames: false);
    } catch (e, stackTrace) {
      AppLogger.e('GamesNotifier', 'fetchCreatedGames failed', e, stackTrace);
      state = state.copyWith(
          errorMyGames: 'Erreur inconnue', isLoadingMyGames: false);
    }
  }

  Future<void> createGame(CreateGameModel data) async {
    state = state.copyWith(isCreating: true, clearErrorCreating: true);
    try {
      final newGame = await ref.read(gamesRepositoryProvider).createGame(data);
      state = state
          .copyWith(isCreating: false, myGames: [newGame, ...state.myGames]);
    } on AppException catch (e) {
      AppLogger.w('GamesNotifier', 'createGame failed: ${e.toString()}');
      state = state.copyWith(errorCreating: e.message, isCreating: false);
    } catch (e, stackTrace) {
      AppLogger.e('GamesNotifier', 'createGame failed', e, stackTrace);
      state = state.copyWith(
          errorCreating: 'Erreur de création', isCreating: false);
    }
  }

  Future<void> updateGame(String gameId, CreateGameModel data) async {
    state = state.copyWith(isUpdating: true, clearErrorUpdating: true);
    try {
      await ref.read(gamesRepositoryProvider).updateGame(gameId, data);
      state = state.copyWith(isUpdating: false);
      await fetchCreatedGames();
    } on AppException catch (e) {
      AppLogger.w('GamesNotifier', 'updateGame failed: ${e.toString()}');
      state = state.copyWith(errorUpdating: e.message, isUpdating: false);
    } catch (e, stackTrace) {
      AppLogger.e('GamesNotifier', 'updateGame failed', e, stackTrace);
      state = state.copyWith(
          errorUpdating: 'Erreur de modification', isUpdating: false);
    }
  }

  Future<void> deleteGame(String gameId) async {
    state = state.copyWith(isDeleting: true, clearErrorDeleting: true);
    try {
      await ref.read(gamesRepositoryProvider).deleteGame(gameId);
      state = state.copyWith(isDeleting: false, clearSelectedGame: true);
      await fetchCreatedGames();
    } on AppException catch (e) {
      AppLogger.w('GamesNotifier', 'deleteGame failed: ${e.toString()}');
      state = state.copyWith(errorDeleting: e.message, isDeleting: false);
    } catch (e, stackTrace) {
      AppLogger.e('GamesNotifier', 'deleteGame failed', e, stackTrace);
      state = state.copyWith(
          errorDeleting: 'Erreur de suppression', isDeleting: false);
    }
  }

  void setDistanceFilter(double distance) {
    state = state.copyWith(distanceFilter: distance);
    fetchExistingGames();
  }

  void setScheduleFilter(double schedule) {
    state = state.copyWith(scheduleFilter: schedule);
    fetchExistingGames();
  }

  void setGameTypeFilter(GameType? gameType) {
    if (gameType == null) {
      state = state.copyWith(clearGameTypeFilter: true);
    } else {
      state = state.copyWith(gameTypeFilter: gameType);
    }
    fetchExistingGames();
  }

  void resetFilters() {
    state = state.copyWith(
      distanceFilter: 30,
      scheduleFilter: 1,
      clearGameTypeFilter: true,
    );
    fetchExistingGames();
  }

  void clearSelectedGame() {
    state = state.copyWith(clearSelectedGame: true);
  }
}
