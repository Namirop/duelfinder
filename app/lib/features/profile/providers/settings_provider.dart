import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
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
    await ref.read(storageServiceProvider).setNotificationsEnabled(enabled);
    // Le token FCM reste toujours enregistré — le push sert de canal de
    // données pour les refresh. Ce setting contrôle uniquement l'affichage
    // des bannières de notification locales.
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
