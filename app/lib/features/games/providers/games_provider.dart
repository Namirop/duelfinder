import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/constants/app_constants.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/entities/game_state.dart';
import 'package:tcg_matchmaker/features/games/models/create_game_model.dart';
import 'package:tcg_matchmaker/features/messages/providers/messages_provider.dart';

part 'games_provider.g.dart';

@Riverpod(keepAlive: true)
class GamesNotifier extends _$GamesNotifier {
  @override
  GamesState build() {
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

      final (dateFrom, dateTo) = _computeDateRange();
      final games = await ref.read(gamesRepositoryProvider).fetchExistingGames(
            latitude: lat,
            longitude: lng,
            distance: state.distanceFilter,
            dateFrom: dateFrom,
            dateTo: dateTo,
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
      // Rafraîchir les conversations pour inclure la nouvelle partie
      ref.read(messagesNotifierProvider.notifier).fetchConversations();
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
      final updated =
          await ref.read(gamesRepositoryProvider).updateGame(gameId, data);
      state = state.copyWith(
        isUpdating: false,
        myGames:
            state.myGames.map((g) => g.id == gameId ? updated : g).toList(),
      );
    } on AppException catch (e) {
      AppLogger.w('GamesNotifier', 'updateGame failed: ${e.toString()}');
      state = state.copyWith(errorUpdating: e.message, isUpdating: false);
    } catch (e, stackTrace) {
      AppLogger.e('GamesNotifier', 'updateGame failed', e, stackTrace);
      state = state.copyWith(
          errorUpdating: 'Erreur de modification', isUpdating: false);
    }
  }

  Future<void> cancelGame(String gameId) async {
    state = state.copyWith(isDeleting: true, clearErrorDeleting: true);
    try {
      await ref.read(gamesRepositoryProvider).deleteGame(gameId);
      // Marquer la partie comme annulée dans les deux listes (sans la supprimer)
      state = state.copyWith(
        isDeleting: false,
        myGames: state.myGames
            .map((g) => g.id == gameId
                ? g.copyWith(
                    status: GameStatus.CANCELLED,
                    effectiveStatus: GameStatus.CANCELLED,
                  )
                : g)
            .toList(),
        existingGames: state.existingGames
            .map((g) => g.id == gameId
                ? g.copyWith(
                    status: GameStatus.CANCELLED,
                    effectiveStatus: GameStatus.CANCELLED,
                  )
                : g)
            .toList(),
      );
    } on AppException catch (e) {
      AppLogger.w('GamesNotifier', 'cancelGame failed: ${e.toString()}');
      state = state.copyWith(errorDeleting: e.message, isDeleting: false);
    } catch (e, stackTrace) {
      AppLogger.e('GamesNotifier', 'cancelGame failed', e, stackTrace);
      state = state.copyWith(
          errorDeleting: 'Erreur d\'annulation', isDeleting: false);
    }
  }

  Future<void> permanentDeleteGame(String gameId) async {
    state = state.copyWith(isDeleting: true, clearErrorDeleting: true);
    try {
      await ref.read(gamesRepositoryProvider).permanentDeleteGame(gameId);
      state = state.copyWith(
        isDeleting: false,
        myGames: state.myGames.where((g) => g.id != gameId).toList(),
        existingGames:
            state.existingGames.where((g) => g.id != gameId).toList(),
      );
    } on AppException catch (e) {
      AppLogger.w('GamesNotifier', 'permanentDeleteGame failed: $e');
      state = state.copyWith(errorDeleting: e.message, isDeleting: false);
    } catch (e, stackTrace) {
      AppLogger.e('GamesNotifier', 'permanentDeleteGame failed', e, stackTrace);
      state = state.copyWith(
          errorDeleting: 'Erreur de suppression', isDeleting: false);
    }
  }

  Future<void> archiveGame(String gameId) async {
    state = state.copyWith(isDeleting: true, clearErrorDeleting: true);
    try {
      await ref.read(gamesRepositoryProvider).archiveGame(gameId);
      state = state.copyWith(
        isDeleting: false,
        myGames: state.myGames.where((g) => g.id != gameId).toList(),
      );
    } on AppException catch (e) {
      AppLogger.w('GamesNotifier', 'archiveGame failed: $e');
      state = state.copyWith(errorDeleting: e.message, isDeleting: false);
    } catch (e, stackTrace) {
      AppLogger.e('GamesNotifier', 'archiveGame failed', e, stackTrace);
      state = state.copyWith(
          errorDeleting: "Erreur d'archivage", isDeleting: false);
    }
  }

  void setDistanceFilter(double distance) {
    state = state.copyWith(distanceFilter: distance);
    fetchExistingGames();
  }

  void setScheduleFilter(ScheduleFilterOption option, {DateTime? customDate}) {
    if (option == ScheduleFilterOption.custom && customDate != null) {
      state = state.copyWith(
        scheduleOption: option,
        customScheduleDate: customDate,
      );
    } else {
      state = state.copyWith(
        scheduleOption: option,
        clearCustomScheduleDate: option != ScheduleFilterOption.custom,
      );
    }
    fetchExistingGames();
  }

  (DateTime?, DateTime?) _computeDateRange() {
    if (state.scheduleOption == ScheduleFilterOption.custom &&
        state.customScheduleDate != null) {
      final d = state.customScheduleDate!;
      final start = DateTime(d.year, d.month, d.day);
      final end = start
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));
      return (start, end);
    }
    return state.scheduleOption.dateRange;
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
      distanceFilter: AppConstants.defaultDistanceKm,
      scheduleOption: ScheduleFilterOption.all,
      clearCustomScheduleDate: true,
      clearGameTypeFilter: true,
    );
    fetchExistingGames();
  }

  void clearSelectedGame() {
    state = state.copyWith(clearSelectedGame: true);
  }

  void decrementCurrentPlayers(String gameId) {
    state = state.copyWith(
      existingGames: state.existingGames
          .map((g) => g.id == gameId && g.currentPlayers > 0
              ? g.copyWith(currentPlayers: g.currentPlayers - 1)
              : g)
          .toList(),
    );
  }
}
