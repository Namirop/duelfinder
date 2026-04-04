import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/core/services/firebase_messaging_service.dart';
import 'package:tcg_matchmaker/features/auth/entities/auth_state.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/notifications/entities/notifications_state.dart';

part 'notifications_provider.g.dart';

/// Initialise Firebase Messaging dès que l'utilisateur est authentifié.
/// keepAlive: true → vit pour toute la durée de la session, jamais détruit.
@Riverpod(keepAlive: true)
class FcmInitializer extends _$FcmInitializer {
  // Champ intentionnel : keepAlive: true garantit que le notifier n'est jamais
  // détruit, donc _service est un singleton de facto. Le check != null empêche
  // une double-initialisation si auth change plusieurs fois.
  FirebaseMessagingService? _service;

  @override
  Future<bool> build() async {
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isAuthenticated) _initFcm();
    });

    final auth = ref.read(authNotifierProvider);
    if (auth.isAuthenticated) {
      await _initFcm();
      return true;
    }

    return false;
  }

  Future<void> _initFcm() async {
    if (_service != null) return;
    try {
      _service = FirebaseMessagingService(
        ref.read(notificationsRepositoryProvider),
        ref,
      );
      await _service!.init();
      AppLogger.d('FcmInitializer', 'FCM initialisé');
    } catch (e, st) {
      AppLogger.e('FcmInitializer', 'FCM init failed', e, st);
    }
  }
}

@Riverpod(keepAlive: true)
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  Future<NotificationsState> build() async {
    final notifications =
        await ref.read(notificationsRepositoryProvider).getNotifications();
    return NotificationsState(notifications: notifications);
  }

  Future<void> fetchNotifications() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final notifications =
          await ref.read(notificationsRepositoryProvider).getNotifications();
      return NotificationsState(notifications: notifications);
    });
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
      state = AsyncData(current.copyWith(
        notifications:
            current.notifications.map((n) => n.copyWith(read: true)).toList(),
      ));
    } catch (e, st) {
      AppLogger.e('NotificationsNotifier', 'markAllRead failed', e, st);
    }
  }

  Future<void> deleteNotification(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      await ref.read(notificationsRepositoryProvider).deleteNotification(id);
      state = AsyncData(current.copyWith(
        notifications: current.notifications.where((n) => n.id != id).toList(),
      ));
    } catch (e, st) {
      AppLogger.e('NotificationsNotifier', 'deleteNotification failed', e, st);
    }
  }
}
