import 'package:flutter/material.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';

class GameMarker extends StatelessWidget {
  final Game game;
  final VoidCallback? onTap;
  final double size;

  const GameMarker({
    super.key,
    required this.game,
    this.onTap,
    this.size = 50,
  });

  /// Retourne la couleur de la bordure selon le statut de la partie.
  /// - Vert : partie ouverte
  /// - Rouge : partie annulée
  /// - Blanc : partie complète ou autre statut
  Color get borderColor {
    switch (game.status) {
      case GameStatus.OPEN:
        return const Color(0xFF4CAF50); // Vert
      case GameStatus.CANCELLED:
        return const Color(0xFFF44336); // Rouge
      case GameStatus.FULL:
      case GameStatus.IN_PROGRESS:
      case GameStatus.COMPLETED:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            game.creator.avatar,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: size * 0.5,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
