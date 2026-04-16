import 'package:dio/dio.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/network/network_info.dart';
import 'package:tcg_matchmaker/core/services/storage_service.dart';

import 'package:tcg_matchmaker/core/constants/api_constants.dart';
import 'package:tcg_matchmaker/features/auth/entities/user.dart';
import 'package:tcg_matchmaker/features/auth/models/dto/login_request_dto.dart';
import 'package:tcg_matchmaker/features/auth/models/dto/register_request_dto.dart';
import 'package:tcg_matchmaker/features/auth/models/user_model.dart';

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
      final request = LoginRequestDto(email: email, password: password);
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
      throw handleDioException(e);
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
      throw handleDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw handleDioException(e);
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

}
