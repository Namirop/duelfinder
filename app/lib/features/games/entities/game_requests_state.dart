import 'package:tcg_matchmaker/features/participations/entities/participation.dart';

class GameRequestsState {
  final List<Participation> participations;
  final bool isLoading;
  final String? error;
  /// IDs des participations en cours de traitement (accept/reject)
  final Set<String> processingIds;

  const GameRequestsState({
    this.participations = const [],
    this.isLoading = false,
    this.error,
    this.processingIds = const {},
  });

  List<Participation> get pending =>
      participations.where((p) => p.isPending).toList();

  List<Participation> get accepted =>
      participations.where((p) => p.isAccepted).toList();

  bool isProcessing(String id) => processingIds.contains(id);

  GameRequestsState copyWith({
    List<Participation>? participations,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Set<String>? processingIds,
  }) {
    return GameRequestsState(
      participations: participations ?? this.participations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      processingIds: processingIds ?? this.processingIds,
    );
  }
}
