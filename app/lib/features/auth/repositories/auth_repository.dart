import 'package:dio/dio.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/network/network_info.dart';
import 'package:tcg_matchmaker/core/services/storage_service.dart';

import '../../../core/constants/api_constants.dart';
import '../entities/user.dart';
import '../models/dto/login_request_dto.dart';
import '../models/dto/register_request_dto.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;
  final StorageService _storageService;

  AuthRepository(this._dio, this._networkInfo, this._storageService);

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestDTO(email: email, password: password);
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      await _storageService.saveTokens(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );
      final userModel = UserModel.fromJson(response.data['user']);
      return userModel.toEntity();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<User> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final request = RegisterRequestDto(
        email: email,
        password: password,
        username: username,
      );

      final response = await _dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      await _storageService.saveTokens(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );
      final userModel = UserModel.fromJson(response.data['user']);
      return userModel.toEntity();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } finally {
      await _storageService.clearTokens();
    }
  }

  Future<User?> getCurrentUser() async {
    final isConnected = await _networkInfo.isConnected;
    final hasTokens = await _storageService.hasTokens();

    if (isConnected && hasTokens) {
      try {
        final response = await _dio.get(ApiConstants.user);
        final userModel = UserModel.fromJson(response.data['user']);
        return userModel.toEntity();
      } on DioException {
        return null;
      }
    }
    return null;
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
          message: errorMessage ?? 'Identifiants requis',
        );
      case 401:
        return UnauthorizedException(
          message: errorMessage ?? 'Identifiants invalides',
        );
      case 403:
        return ForbiddenException(
          message: errorMessage ?? 'Accès refusé',
        );
      case 404:
        return NotFoundException(
          message: errorMessage ?? 'Ressource introuvable',
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
