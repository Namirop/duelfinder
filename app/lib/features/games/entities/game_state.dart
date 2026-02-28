import 'package:tcg_matchmaker/features/games/entities/game.dart';

class GamesState {
  final List<Game> existingGames;
  final List<Game> myGames;
  final List<Game> joinedGames;
  final Game? selectedGame;

  // Filtres
  final double distanceFilter;

  // Loading states pour les listes
  final bool isLoadingExisting;
  final bool isLoadingMyGames;
  final bool isLoadingJoined;

  // Loading states pour les opérations CRUD
  final bool isLoadingDetails;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  // Erreurs pour les listes
  final String? errorExisting;
  final String? errorMyGames;
  final String? errorJoined;

  // Erreurs pour les opérations CRUD
  final String? errorDetails;
  final String? errorCreating;
  final String? errorUpdating;
  final String? errorDeleting;

  const GamesState({
    this.existingGames = const [],
    this.myGames = const [],
    this.joinedGames = const [],
    this.selectedGame,
    this.distanceFilter = 30,
    this.isLoadingExisting = false,
    this.isLoadingMyGames = false,
    this.isLoadingJoined = false,
    this.isLoadingDetails = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorExisting,
    this.errorMyGames,
    this.errorJoined,
    this.errorDetails,
    this.errorCreating,
    this.errorUpdating,
    this.errorDeleting,
  });

  bool get hasExistingGames => existingGames.isNotEmpty;
  bool get hasCreatedGames => myGames.isNotEmpty;
  bool get hasJoinedGames => joinedGames.isNotEmpty;
  bool get hasSelectedGame => selectedGame != null;

  GamesState copyWith({
    List<Game>? existingGames,
    List<Game>? myGames,
    List<Game>? joinedGames,
    Game? selectedGame,
    double? distanceFilter,
    bool? isLoadingExisting,
    bool? isLoadingMyGames,
    bool? isLoadingJoined,
    bool? isLoadingDetails,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorExisting,
    String? errorMyGames,
    String? errorJoined,
    String? errorDetails,
    String? errorCreating,
    String? errorUpdating,
    String? errorDeleting,
    bool clearSelectedGame = false,
    bool clearErrorExisting = false,
    bool clearErrorMyGames = false,
    bool clearErrorJoined = false,
    bool clearErrorDetails = false,
    bool clearErrorCreating = false,
    bool clearErrorUpdating = false,
    bool clearErrorDeleting = false,
  }) {
    return GamesState(
      existingGames: existingGames ?? this.existingGames,
      myGames: myGames ?? this.myGames,
      joinedGames: joinedGames ?? this.joinedGames,
      selectedGame:
          clearSelectedGame ? null : (selectedGame ?? this.selectedGame),
      distanceFilter: distanceFilter ?? this.distanceFilter,
      isLoadingExisting: isLoadingExisting ?? this.isLoadingExisting,
      isLoadingMyGames: isLoadingMyGames ?? this.isLoadingMyGames,
      isLoadingJoined: isLoadingJoined ?? this.isLoadingJoined,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorExisting:
          clearErrorExisting ? null : (errorExisting ?? this.errorExisting),
      errorMyGames:
          clearErrorMyGames ? null : (errorMyGames ?? this.errorMyGames),
      errorJoined: clearErrorJoined ? null : (errorJoined ?? this.errorJoined),
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
  joined;

  String label(int count) => switch (this) {
        GameView.created => 'Créées ($count)',
        GameView.joined => 'Rejointes ($count)',
      };
}
