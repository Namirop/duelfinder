import 'package:dio/dio.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/features/notifications/entities/notification.dart';
import 'package:tcg_matchmaker/features/notifications/models/notification_model.dart';

class NotificationsRepository {
  final Dio _dio;

  NotificationsRepository(this._dio);

  Future<void> registerFcmToken(String token) async {
    try {
      await _dio.put('/users/me/fcm-token', data: {'token': token});
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? 'Erreur enregistrement token FCM',
      );
    }
  }

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return (response.data as List)
          .map((json) => NotificationModel.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? 'Erreur chargement notifications',
      );
    }
  }

  Future<bool> hasUnread() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return (response.data['count'] as int) > 0;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? 'Erreur lecture notifications',
      );
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? 'Erreur mise à jour notifications',
      );
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('/notifications/$id');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? 'Erreur suppression notification',
      );
    }
  }
}
