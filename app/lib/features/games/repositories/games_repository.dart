import 'package:dio/dio.dart';
import 'package:tcg_matchmaker/core/constants/api_constants.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/models/create_game_model.dart';
import 'package:tcg_matchmaker/features/games/models/game_model.dart';

class GamesRepository {
  final Dio _dio;

  GamesRepository(this._dio);

  Future<List<Game>> fetchExistingGames({
    required double latitude,
    required double longitude,
    double distance = 30,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.existingGames,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'distance': distance,
        },
      );
      return (response.data as List)
          .map((json) =>
              GameModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<Game>> fetchCreatedGames() async {
    try {
      final response = await _dio.get(ApiConstants.myGames);
      return (response.data as List)
          .map((json) =>
              GameModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<Game>> fetchJoinedGames() async {
    try {
      return List.empty();
      // final response = await _dio.get(ApiConstants.joinedGames);
      // final List<dynamic> data = response.data['games'];
      // final gamesModel = data.map((json) => GameModel.fromJson(json)).toList();
      // return gamesModel.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Game> getGameById(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.game}/$id');
      final gameModel = GameModel.fromJson(response.data['game']);
      return gameModel.toEntity();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Game> createGame(CreateGameModel data) async {
    try {
      final response = await _dio.post(
        ApiConstants.game,
        data: data.toJson(),
      );
      final gameModel =
          GameModel.fromJson(response.data as Map<String, dynamic>);
      return gameModel.toEntity();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Game> updateGame(String id, CreateGameModel data) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.game}/$id',
        data: data.toJson(),
      );
      final gameModel =
          GameModel.fromJson(response.data as Map<String, dynamic>);
      return gameModel.toEntity();
    } on DioException catch (e) {
      print("ici");
      throw _handleDioException(e);
    }
  }

  Future<void> deleteGame(String id) async {
    try {
      await _dio.delete('${ApiConstants.game}/$id');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  AppException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException(message: 'Pas de connexion internet');
    }

    final errorMessage = e.response?.data['error'] as String?;

    switch (e.response?.statusCode) {
      case 400:
        return ValidationException(
          message: errorMessage ?? 'Données invalides',
        );
      case 401:
        return UnauthorizedException(
          message: errorMessage ?? 'Non authentifié',
        );
      case 403:
        return ForbiddenException(
          message: errorMessage ?? 'Accès refusé',
        );
      case 404:
        return NotFoundException(
          message: errorMessage ?? 'Partie introuvable',
        );
      case 422:
        return ValidationException(
          message: errorMessage ?? 'Données invalides',
        );
      default:
        return ServerException(
          message: errorMessage ?? 'Erreur serveur',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
