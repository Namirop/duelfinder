import 'package:dio/dio.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';

class NotificationsRepository {
  final Dio _dio;

  NotificationsRepository(this._dio);

  /// Enregistre ou met à jour le token FCM de l'utilisateur connecté
  Future<void> registerFcmToken(String token) async {
    try {
      await _dio.put('/users/me/fcm-token', data: {'token': token});
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? 'Erreur enregistrement token FCM',
      );
    }
  }
}
