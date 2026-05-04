import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/profile/entities/location_permission_result.dart';
import 'package:tcg_matchmaker/features/profile/entities/settings_state.dart';

export 'package:tcg_matchmaker/features/profile/entities/location_permission_result.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsState build() {
    _loadNotificationPref();
    return const SettingsState();
  }

  Future<void> _loadNotificationPref() async {
    final storage = ref.read(storageServiceProvider);
    final enabled = await storage.getNotificationsEnabled();
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);

    final storage = ref.read(storageServiceProvider);
    await storage.setNotificationsEnabled(enabled);

    final repo = ref.read(notificationsRepositoryProvider);
    try {
      if (enabled) {
        // Re-register FCM token
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await repo.registerFcmToken(token);
        }
      } else {
        // Clear FCM token → backend won't send push
        await repo.clearFcmToken();
      }
    } catch (e) {
      AppLogger.w('SettingsNotifier', 'FCM token toggle failed: $e');
    }
  }

  void setLocationEnabledSilently(bool enabled) {
    state = state.copyWith(locationEnabled: enabled);
    // sync bridge si tu le gardes
    ref.read(locationEnabledProvider.notifier).state = enabled;
  }

  Future<LocationPermissionResult> toggleLocation(bool enabled) async {
    if (enabled) {
      final hasPermission =
          await ref.read(locationServiceProvider).checkPermission();
      if (!hasPermission) {
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationPermissionResult.denied;
        }
        if (permission == LocationPermission.deniedForever) {
          return LocationPermissionResult.deniedForever;
        }
      }
    }
    setLocationEnabledSilently(enabled);
    return LocationPermissionResult.granted;
  }
}
