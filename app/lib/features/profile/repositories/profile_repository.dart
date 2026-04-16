import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  // À remplir avec vos identifiants Cloudinary
  static const _cloudName = 'dmnke77es';
  static const _uploadPreset = 'duelfinder';

  Future<User> uploadAvatar(File imageFile) async {
    try {
      // 1. Lire les bytes en mémoire (évite les problèmes de chemin Android)
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.path.split('/').last;

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

      final streamedResponse = await request.send();
      final body = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode != 200) {
        throw ServerException(message: 'Erreur upload photo (${streamedResponse.statusCode})');
      }

      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final downloadUrl = decoded['secure_url'] as String?;

      if (downloadUrl == null || downloadUrl.isEmpty) {
        throw ServerException(message: 'Erreur upload photo : URL manquante');
      }

      // 2. Sauvegarder l'URL dans le backend
      final response = await _dio.put(
        ApiConstants.usersMe,
        data: {'avatar': downloadUrl},
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
