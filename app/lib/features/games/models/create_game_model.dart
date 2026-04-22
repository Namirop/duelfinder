import 'package:tcg_matchmaker/features/games/entities/game.dart';

class CreateGameModel {
  final GameType gameType;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final double? approximateLatitude;
  final double? approximateLongitude;
  final DateTime scheduledAt;
  final int duration;
  final int maxPlayers;

  const CreateGameModel({
    required this.gameType,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.approximateLatitude,
    this.approximateLongitude,
    required this.scheduledAt,
    required this.duration,
    required this.maxPlayers,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.name,
      if (description != null) 'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      if (approximateLatitude != null)
        'approximateLatitude': approximateLatitude,
      if (approximateLongitude != null)
        'approximateLongitude': approximateLongitude,
      'scheduledAt': scheduledAt.toIso8601String(),
      'duration': duration,
      'maxPlayers': maxPlayers,
    };
  }
}
