import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/core/services/firebase_messaging_service.dart';
import 'package:tcg_matchmaker/features/auth/entities/auth_state.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/notifications/entities/notification.dart';

part 'notifications_provider.g.dart';

/// Initialise Firebase Messaging dès que l'utilisateur est authentifié.
/// keepAlive: true → vit pour toute la durée de la session, jamais détruit.
@Riverpod(keepAlive: true)
class FcmInitializer extends _$FcmInitializer {
  FirebaseMessagingService? _service;

  @override
  bool build() {
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isAuthenticated && _service == null) {
        _initFcm();
      }
    });

    final auth = ref.read(authNotifierProvider);
    if (auth.isAuthenticated && _service == null) {
      Future.microtask(_initFcm);
    }

    return false;
  }

  Future<void> _initFcm() async {
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

final hasUnreadProvider = FutureProvider<bool>((ref) async {
  return ref.read(notificationsRepositoryProvider).hasUnread();
});

class NotificationsListNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    return ref.read(notificationsRepositoryProvider).getNotifications();
  }

  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllRead();
    state = state.whenData(
      (list) => list.map((n) => n.copyWith(read: true)).toList(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(notificationsRepositoryProvider).deleteNotification(id);
    state = state.whenData(
      (list) => list.where((n) => n.id != id).toList(),
    );
  }
}

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsListNotifier, List<AppNotification>>(
  NotificationsListNotifier.new,
);
