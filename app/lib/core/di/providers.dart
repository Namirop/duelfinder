import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tcg_matchmaker/core/constants/app_constants.dart';
import 'package:tcg_matchmaker/core/network/dio_client.dart';
import 'package:tcg_matchmaker/core/network/network_info.dart';
import 'package:tcg_matchmaker/core/services/location_service.dart';
import 'package:tcg_matchmaker/core/services/storage_service.dart';
import 'package:tcg_matchmaker/features/auth/repositories/auth_repository.dart';
import 'package:tcg_matchmaker/features/games/repositories/games_repository.dart';
import 'package:tcg_matchmaker/features/messages/repositories/messages_repository.dart';
import 'package:tcg_matchmaker/features/notifications/repositories/notifications_repository.dart';
import 'package:tcg_matchmaker/features/participations/repositories/participations_repository.dart';
import 'package:tcg_matchmaker/features/profile/repositories/profile_repository.dart';

// Core services
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});

/// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(networkInfoProvider),
    ref.watch(storageServiceProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository(ref.watch(dioProvider));
});

final participationsRepositoryProvider =
    Provider<ParticipationsRepository>((ref) {
  return ParticipationsRepository(ref.watch(dioProvider));
});

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepository(ref.watch(dioProvider));
});

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(dioProvider));
});

final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Location
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentPositionProvider = FutureProvider<Position?>((ref) async {
  // Vérifie d'abord si l'utilisateur a activé la géolocalisation
  final locationEnabled = ref.watch(locationEnabledProvider);
  if (!locationEnabled) {
    return null;
  }

  final locationService = ref.watch(locationServiceProvider);
  return locationService
      .getCurrentPosition()
      .timeout(const Duration(seconds: AppConstants.locationTimeoutSeconds), onTimeout: () => null);
});

// Provider pour la préférence utilisateur de géolocalisation (en mémoire pour V1)
final locationEnabledProvider = StateProvider<bool>((ref) => true);
