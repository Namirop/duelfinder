import 'package:dio/dio.dart';
import 'package:tcg_matchmaker/core/constants/api_constants.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation.dart';
import 'package:tcg_matchmaker/features/participations/models/participation_model.dart';

class ParticipationsRepository {
  final Dio _dio;

  ParticipationsRepository(this._dio);

  Future<List<Participation>> getMyParticipations({String? status}) async {
    try {
      final queryParams = {if (status != null) 'status': status};

      final response = await _dio.get(
        ApiConstants.myParticipations,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return (response.data as List)
          .map((json) =>
              ParticipationModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<Participation>> getGameParticipations(String gameId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.games}/$gameId/participations',
      );

      return (response.data as List)
          .map((json) =>
              ParticipationModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Participation> requestToJoin(String gameId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.games}/$gameId/participations',
      );

      return ParticipationModel.fromJson(response.data as Map<String, dynamic>)
          .toEntity();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Participation> cancelParticipation(String participationId) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.participations}/$participationId/cancel',
      );
      return ParticipationModel.fromJson(response.data as Map<String,
              dynamic>) // ne renvoie pas de game dans participation, pas d'erreur car game peut etre null
          .toEntity();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Participation> acceptParticipation(String participationId) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.participations}/$participationId/accept',
      );

      final data = response.data as Map<String, dynamic>;
      return ParticipationModel.fromJson(
              data['participation'] as Map<String, dynamic>)
          .toEntity();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Participation> rejectParticipation(String participationId) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.participations}/$participationId/reject',
      );

      return ParticipationModel.fromJson(response.data as Map<String, dynamic>)
          .toEntity();
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
          message: errorMessage ?? 'Ressource introuvable',
        );
      case 429:
        return ValidationException(
          message: errorMessage ?? 'Trop de requêtes',
        );
      default:
        return ServerException(
          message: errorMessage ?? 'Erreur serveur',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
