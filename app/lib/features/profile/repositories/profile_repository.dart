import 'package:dio/dio.dart';
import 'package:tcg_matchmaker/core/constants/api_constants.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/features/auth/entities/user.dart';
import 'package:tcg_matchmaker/features/auth/models/user_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<User> updateProfile({String? username, String? bio}) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;

      final response = await _dio.put(ApiConstants.usersMe, data: data);
      return UserModel.fromJson(response.data['user']).toEntity();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        ApiConstants.usersMePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete(ApiConstants.usersMe);
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
          message: errorMessage ?? 'Non autorisé',
        );
      case 409:
        return ValidationException(
          message: errorMessage ?? 'Conflit de données',
        );
      default:
        return ServerException(
          message: errorMessage ?? 'Erreur serveur',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
