import 'dart:io';

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
      throw handleDioException(e);
    }
  }

  Future<User> uploadAvatar(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _dio.put(
        ApiConstants.usersMeAvatar,
        data: formData,
      );

      return UserModel.fromJson(response.data['user']).toEntity();
    } on DioException catch (e) {
      throw handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Erreur lors de l\'upload de la photo');
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
      throw handleDioException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete(ApiConstants.usersMe);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

}
