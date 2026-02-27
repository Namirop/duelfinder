import 'package:tcg_matchmaker/features/auth/entities/user_summary.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';

const mockCreator1 = UserSummary(
    id: 'user-1',
    username: 'Ash Ketchum',
    avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=user-1");

const mockCreator2 = UserSummary(
    id: 'user-2',
    username: 'Ben Zoukam',
    avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=user-2");

final List<Game> mockGames = [
  Game(
    id: 'game-1',
    gameType: GameType.POKEMON,
    description: 'Partie débutants bienvenue',
    address: 'Place du Général de Gaulle, Lille',
    latitude: 50.6292,
    longitude: 3.0573,
    scheduledAt: DateTime.now().add(const Duration(hours: 2)),
    duration: 60,
    maxPlayers: 4,
    status: GameStatus.OPEN,
    creator: mockCreator1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Game(
    id: 'game-2',
    gameType: GameType.ONE_PIECE,
    address: 'Rue Nationale, Lille',
    latitude: 50.6310,
    longitude: 3.0590,
    scheduledAt: DateTime.now().add(const Duration(hours: 5)),
    duration: 90,
    maxPlayers: 2,
    status: GameStatus.CANCELLED,
    creator: mockCreator2,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Game(
    id: 'game-3',
    gameType: GameType.POKEMON,
    address: 'Place de la Gaulle de Gaulle, Lille',
    latitude: 50.6292,
    longitude: 3.0573,
    scheduledAt: DateTime.now().add(const Duration(hours: 2)),
    duration: 80,
    maxPlayers: 4,
    status: GameStatus.CANCELLED,
    creator: mockCreator1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Game(
    id: 'game-4',
    gameType: GameType.YUGIOH,
    address: 'Place du Fion de Gaulle, Lille',
    latitude: 50.6292,
    longitude: 3.0573,
    scheduledAt: DateTime.now().add(const Duration(hours: 1)),
    duration: 30,
    maxPlayers: 4,
    status: GameStatus.IN_PROGRESS,
    creator: mockCreator1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Game(
    id: 'game-5',
    gameType: GameType.YUGIOH,
    address: 'Place du Caca de Gaulle, Lille',
    latitude: 50.6292,
    longitude: 3.0573,
    scheduledAt: DateTime.now().add(const Duration(hours: 10)),
    duration: 20,
    maxPlayers: 3,
    status: GameStatus.FULL,
    creator: mockCreator1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  // autant que t'as besoin
];
