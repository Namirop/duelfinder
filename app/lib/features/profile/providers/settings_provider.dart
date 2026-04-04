import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/features/profile/entities/settings_state.dart';

part 'settings_provider.g.dart';

enum LocationPermissionResult {
  granted,
  denied,
  deniedForever,
}

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
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
