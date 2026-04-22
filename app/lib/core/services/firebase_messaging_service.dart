import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/messages/providers/messages_provider.dart';
import 'package:tcg_matchmaker/features/notifications/providers/notifications_provider.dart';
import 'package:tcg_matchmaker/features/notifications/repositories/notifications_repository.dart';
import 'package:tcg_matchmaker/features/participations/providers/participations_notifier.dart';

class FirebaseMessagingService {
  final NotificationsRepository _repository;
  final Ref _ref;

  static const _channelId = 'duelfinder_high';
  static const _channelName = 'Notifications DuelFinder';

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _channel = const AndroidNotificationChannel(
    _channelId,
    _channelName,
    importance: Importance.high,
  );

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

    // Toujours rafraîchir la liste de notifications in-app (le backend a créé
    // l'enregistrement en DB au moment de l'envoi du push)
    _ref.read(notificationsNotifierProvider.notifier).fetchNotifications();

    // Refresh silencieux des données selon le type de notification
    // switch avec fallthrough — 
    //par exemple, PARTICIPATION_REQUEST n'a pas de break, donc il tombe dans le bloc de PARTICIPATION_CANCELLED juste en dessous
    switch (type) {
      case 'PARTICIPATION_REQUEST':
      case 'PARTICIPATION_CANCELLED':
        _ref.read(gamesNotifierProvider.notifier).fetchCreatedGames();
        break;
      case 'PARTICIPATION_ACCEPTED':
      case 'PARTICIPATION_REJECTED':
      case 'GAME_FULL':
      case 'GAME_CANCELLED':
        _ref
            .read(participationsNotifierProvider.notifier)
            .fetchMyParticipations();
        _ref.read(gamesNotifierProvider.notifier).fetchExistingGames();
        break;
      case 'NEW_MESSAGE':
        _ref.read(messagesNotifierProvider.notifier).fetchConversations();
        break;
    }
  }
}
