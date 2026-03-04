import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/notifications/repositories/notifications_repository.dart';
import 'package:tcg_matchmaker/features/participations/providers/participations_notifier.dart';

class FirebaseMessagingService {
  final NotificationsRepository _repository;
  final Ref _ref;

  FirebaseMessagingService(this._repository, this._ref);

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Demander la permission (Android 13+, iOS)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Récupérer le token et l'enregistrer côté backend
    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // Mettre à jour le token si Firebase le renouvelle
    messaging.onTokenRefresh.listen(_registerToken);

    // Messages reçus quand l'app est en foreground → refresh silencieux
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

    switch (type) {
      // Le créateur reçoit une demande → refresh ses demandes
      case 'PARTICIPATION_REQUEST':
      case 'PARTICIPATION_CANCELLED':
        _ref
            .read(participationsNotifierProvider.notifier)
            .fetchMyParticipations();
        _ref.read(gamesNotifierProvider.notifier).fetchCreatedGames();
        break;

      // Le joueur reçoit une réponse ou infos sur la partie
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
