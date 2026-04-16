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
      throw handleDioException(e);
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
      throw handleDioException(e);
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
      throw handleDioException(e);
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
      throw handleDioException(e);
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
      throw handleDioException(e);
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
      throw handleDioException(e);
    }
  }

}
