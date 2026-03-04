import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/auth/entities/auth_state.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/notifications/services/firebase_messaging_service.dart';

part 'notifications_provider.g.dart';

/// Initialise Firebase Messaging dès que l'utilisateur est authentifié.
/// keepAlive: true → vit pour toute la durée de la session, jamais détruit.
@Riverpod(keepAlive: true)
class FcmInitializer extends _$FcmInitializer {
  FirebaseMessagingService? _service;

  @override
  bool build() {
    // Écoute les changements d'état d'auth
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isAuthenticated && _service == null) {
        _initFcm();
      }
    });

    // Cas où l'utilisateur est déjà connecté au premier build
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
