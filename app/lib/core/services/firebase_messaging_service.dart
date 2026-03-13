import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/notifications/repositories/notifications_repository.dart';
import 'package:tcg_matchmaker/features/participations/providers/participations_notifier.dart';

/// Canal Android avec importance HIGH → déclenche les bannières popup
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'duelfinder_high',
  'Notifications DuelFinder',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

class FirebaseMessagingService {
  final NotificationsRepository _repository;
  final Ref _ref;

  FirebaseMessagingService(this._repository, this._ref);

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Créer le canal Android HIGH importance (bannières popup)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Initialiser flutter_local_notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(initSettings);

    // Récupérer le token et l'enregistrer côté backend
    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // Mettre à jour le token si Firebase le renouvelle
    messaging.onTokenRefresh.listen(_registerToken);

    // Messages en foreground → afficher une bannière locale + refresh data
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _registerToken(String token) async {
    try {
      await _repository.registerFcmToken(token);
    } catch (e) {
      AppLogger.w('FirebaseMessagingService', 'Token registration failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final type = message.data['type'];
    AppLogger.d('FirebaseMessagingService', 'Foreground message: $type');

    // Afficher une notification locale (bannière popup)
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }

    // Refresh silencieux des données selon le type
    switch (type) {
      case 'PARTICIPATION_REQUEST':
      case 'PARTICIPATION_CANCELLED':
        _ref
            .read(participationsNotifierProvider.notifier)
            .fetchMyParticipations();
        _ref.read(gamesNotifierProvider.notifier).fetchCreatedGames();
        break;
      case 'PARTICIPATION_ACCEPTED':
      case 'PARTICIPATION_REJECTED':
      case 'GAME_FULL':
      case 'GAME_CANCELLED':
        _ref
            .read(participationsNotifierProvider.notifier)
            .fetchMyParticipations();
        break;
    }
  }
}
