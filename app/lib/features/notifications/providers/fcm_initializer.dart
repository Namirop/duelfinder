import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/core/services/firebase_messaging_service.dart';

part 'fcm_initializer.g.dart';

/// Initialise Firebase Messaging (token + listeners).
/// keepAlive: true → singleton pour toute la session.
/// Déclenché explicitement par MainShell._requestPermissionsAndLoadInitialData(),
/// pas de check auth ici car MainShell ne monte que si l'user est authentifié.
@Riverpod(keepAlive: true)
class FcmInitializer extends _$FcmInitializer {
  bool _initialized = false;

  /// false = pas encore initialisé, true = FCM prêt.
  /// Notifier<bool> impose un retour dans build, pas utilisé ailleurs.
  @override
  bool build() {
    return false;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final service = FirebaseMessagingService(
        ref.read(notificationsRepositoryProvider),
        ref,
      );
      await service.init();
      _initialized = true;
      state = true;
      AppLogger.d('FcmInitializer', 'FCM initialisé');
    } catch (e, st) {
      AppLogger.e('FcmInitializer', 'FCM init failed', e, st);
    }
  }
}
