import 'package:tcg_matchmaker/features/games/entities/game.dart';

class GamesState {
  final List<Game> existingGames;
  final List<Game> myGames;
  final Game? selectedGame;

  // Filtres
  final double distanceFilter;
  final double scheduleFilter;
  final GameType? gameTypeFilter; // null = tous les jeux

  // Loading states pour les listes
  final bool isLoadingExisting;
  final bool isLoadingMyGames;

  // Loading states pour les opérations CRUD
  final bool isLoadingDetails;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  // Erreurs pour les listes
  final String? errorExisting;
  final String? errorMyGames;

  // Erreurs pour les opérations CRUD
  final String? errorDetails;
  final String? errorCreating;
  final String? errorUpdating;
  final String? errorDeleting;

  const GamesState({
    this.existingGames = const [],
    this.myGames = const [],
    this.selectedGame,
    this.distanceFilter = 30,
    this.scheduleFilter = 1,
    this.gameTypeFilter, // null = tous les jeux
    this.isLoadingExisting = false,
    this.isLoadingMyGames = false,
    this.isLoadingDetails = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorExisting,
    this.errorMyGames,
    this.errorDetails,
    this.errorCreating,
    this.errorUpdating,
    this.errorDeleting,
  });

  bool get hasExistingGames => existingGames.isNotEmpty;
  bool get hasCreatedGames => myGames.isNotEmpty;
  bool get hasSelectedGame => selectedGame != null;

  GamesState copyWith({
    List<Game>? existingGames,
    List<Game>? myGames,
    Game? selectedGame,
    double? distanceFilter,
    double? scheduleFilter,
    GameType? gameTypeFilter,
    bool? isLoadingExisting,
    bool? isLoadingMyGames,
    bool? isLoadingDetails,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorExisting,
    String? errorMyGames,
    String? errorDetails,
    String? errorCreating,
    String? errorUpdating,
    String? errorDeleting,
    bool clearSelectedGame = false,
    bool clearGameTypeFilter = false,
    bool clearErrorExisting = false,
    bool clearErrorMyGames = false,
    bool clearErrorDetails = false,
    bool clearErrorCreating = false,
    bool clearErrorUpdating = false,
    bool clearErrorDeleting = false,
  }) {
    return GamesState(
      existingGames: existingGames ?? this.existingGames,
      myGames: myGames ?? this.myGames,
      selectedGame:
          clearSelectedGame ? null : (selectedGame ?? this.selectedGame),
      distanceFilter: distanceFilter ?? this.distanceFilter,
      scheduleFilter: scheduleFilter ?? this.scheduleFilter,
      gameTypeFilter:
          clearGameTypeFilter ? null : (gameTypeFilter ?? this.gameTypeFilter),
      isLoadingExisting: isLoadingExisting ?? this.isLoadingExisting,
      isLoadingMyGames: isLoadingMyGames ?? this.isLoadingMyGames,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorExisting:
          clearErrorExisting ? null : (errorExisting ?? this.errorExisting),
      errorMyGames:
          clearErrorMyGames ? null : (errorMyGames ?? this.errorMyGames),
      errorDetails:
          clearErrorDetails ? null : (errorDetails ?? this.errorDetails),
      errorCreating:
          clearErrorCreating ? null : (errorCreating ?? this.errorCreating),
      errorUpdating:
          clearErrorUpdating ? null : (errorUpdating ?? this.errorUpdating),
      errorDeleting:
          clearErrorDeleting ? null : (errorDeleting ?? this.errorDeleting),
    );
  }
}

enum GameView {
  created,
  participations;

  String label(int count) => switch (this) {
        GameView.created => 'Créées ($count)',
        GameView.participations => 'Participations ($count)',
      };
}
