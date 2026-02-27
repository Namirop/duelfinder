import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_provider.g.dart';

/// Provider pour les notifications
/// TODO: Implémenter la logique de gestion des notifications
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  AsyncValue<void> build() {
    // TODO: Charger les notifications
    return const AsyncValue.data(null);
  }

  // TODO: Implémenter loadNotifications()
  // TODO: Implémenter markAsRead(notificationId)
  // TODO: Implémenter markAllAsRead()
  // TODO: Implémenter refresh()
}

/// Provider pour le compteur de notifications non lues
@riverpod
int unreadNotificationsCount(UnreadNotificationsCountRef ref) {
  // TODO: Calculer le nombre de notifications non lues
  return 0;
}

/// Service pour gérer Firebase Messaging
/// TODO: Implémenter la logique FCM
class FirebaseMessagingService {
  // TODO: Implémenter init() - initialiser FCM
  // TODO: Implémenter getToken() - obtenir le token FCM
  // TODO: Implémenter onTokenRefresh() - écouter le refresh du token
  // TODO: Implémenter onMessage() - écouter les messages en foreground
  // TODO: Implémenter onBackgroundMessage() - messages en background
}
