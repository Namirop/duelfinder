import 'package:tcg_matchmaker/features/auth/entities/user_summary.dart';
import 'package:tcg_matchmaker/features/games/entities/game_enums.dart';

export 'package:tcg_matchmaker/features/games/entities/game_enums.dart'; // export = "ceux qui m'importent reçoivent aussi ça"

class Game {
  final String id;
  final GameType gameType;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime scheduledAt;
  final int duration;
  final int maxPlayers;
  final GameStatus status;
  final GameStatus effectiveStatus; // status + logique temporelle (pour UI)
  final int currentPlayers;
  final UserSummary creator;
  final List<UserSummary> participants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance;
  final int pendingCount;
  final bool addressMasked;

  const Game({
    required this.id,
    required this.gameType,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.scheduledAt,
    required this.duration,
    required this.maxPlayers,
    required this.status,
    required this.effectiveStatus,
    required this.currentPlayers,
    required this.creator,
    this.participants = const [],
    required this.createdAt,
    required this.updatedAt,
    this.distance,
    this.pendingCount = 0,
    this.addressMasked = false,
  });

  bool get isFull => currentPlayers >= maxPlayers;
  bool get hasAvailableSpots => currentPlayers < maxPlayers;
  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());
  bool get isOpen => effectiveStatus == GameStatus.OPEN;

  /// Retourne "Rue, Ville" sans le numéro (ex: "Boulevard Audent, Charleroi")
  String get streetOnly {
    final parts = address.split(',');
    // Supprimer le numéro de rue en fin de chaîne (ex: "Boulevard Audent 12")
    final street =
        parts.first.trim().replaceAll(RegExp(r'\s+\d+\s*$'), '').trim();
    if (parts.length > 1) return '$street, ${parts[1].trim()}';
    return street;
  }

  /// Heure de fin calculée (scheduledAt + duration)
  DateTime get endTime => scheduledAt.add(Duration(minutes: duration));

  Game copyWith({
    String? id,
    GameType? gameType,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? scheduledAt,
    int? duration,
    int? maxPlayers,
    GameStatus? status,
    GameStatus? effectiveStatus,
    int? currentPlayers,
    UserSummary? creator,
    List<UserSummary>? participants,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
    int? pendingCount,
    bool? addressMasked,
  }) {
    return Game(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      duration: duration ?? this.duration,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      status: status ?? this.status,
      effectiveStatus: effectiveStatus ?? this.effectiveStatus,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      creator: creator ?? this.creator,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
      pendingCount: pendingCount ?? this.pendingCount,
      addressMasked: addressMasked ?? this.addressMasked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Game && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
