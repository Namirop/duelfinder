import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/notifications/entities/notifications_state.dart';

part 'notifications_provider.g.dart';

@Riverpod(keepAlive: true)
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  NotificationsState build() {
    return const NotificationsState();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final notifications =
          await ref.read(notificationsRepositoryProvider).getNotifications();
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
      );
    } on AppException catch (e) {
      AppLogger.w('NotificationsNotifier',
          'fetchNotifications failed: ${e.toString()}');
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e, stackTrace) {
      AppLogger.e(
          'NotificationsNotifier', 'fetchNotifications failed', e, stackTrace);
      state = state.copyWith(error: 'Erreur inconnue', isLoading: false);
    }
  }

  Future<void> markAllRead() async {
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
      state = state.copyWith(
        notifications:
            state.notifications.map((n) => n.copyWith(read: true)).toList(),
      );
    } catch (e, st) {
      AppLogger.e('NotificationsNotifier', 'markAllRead failed', e, st);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await ref.read(notificationsRepositoryProvider).deleteNotification(id);
      state = state.copyWith(
        notifications: state.notifications.where((n) => n.id != id).toList(),
      );
    } catch (e, st) {
      AppLogger.e('NotificationsNotifier', 'deleteNotification failed', e, st);
    }
  }
}
