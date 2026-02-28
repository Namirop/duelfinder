import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';

class GameDetailsSheet extends StatelessWidget {
  final Game game;

  const GameDetailsSheet({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec avatar et infos créateur
                _buildHeader(theme, colorScheme),
                const SizedBox(height: 20),

                // Type de jeu
                _buildGameType(theme, colorScheme),
                const SizedBox(height: 16),

                // Date et heure
                _buildDateTime(theme, colorScheme),
                const SizedBox(height: 12),

                // Lieu
                _buildLocation(theme, colorScheme),
                const SizedBox(height: 12),

                // Joueurs
                _buildPlayers(theme, colorScheme),
                const SizedBox(height: 12),

                // Description (si présente)
                if (game.description != null && game.description!.isNotEmpty)
                  _buildDescription(theme, colorScheme),

                const SizedBox(height: 24),

                // Bouton rejoindre
                _buildJoinButton(theme, colorScheme),

                // Safe area pour le bottom
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    final statusColor = game.effectiveStatus.markerColor;

    return Row(
      children: [
        // Avatar avec bordure de statut
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: statusColor,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(game.creator.avatar),
            backgroundColor: colorScheme.primaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.creator.username,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  game.effectiveStatus.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameType(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.style_outlined,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            game.gameType.label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTime(ThemeData theme, ColorScheme colorScheme) {
    final dateFormat = DateFormat('EEEE d MMMM', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(game.scheduledAt),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${timeFormat.format(game.scheduledAt)} - ${game.duration} min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            game.address,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayers(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.people_outline,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '${game.maxPlayers} joueurs max',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'Description',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          game.description!,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildJoinButton(ThemeData theme, ColorScheme colorScheme) {
    final canJoin = game.effectiveStatus == GameStatus.OPEN;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canJoin ? () {
          // TODO: Implémenter la logique pour rejoindre
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          canJoin ? 'Rejoindre la partie' : _getDisabledButtonText(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: canJoin ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  String _getDisabledButtonText() {
    switch (game.effectiveStatus) {
      case GameStatus.FULL:
        return 'Partie complète';
      case GameStatus.CANCELLED:
        return 'Partie annulée';
      case GameStatus.IN_PROGRESS:
        return 'Partie en cours';
      case GameStatus.FINISHED:
        return 'Partie terminée';
      default:
        return 'Non disponible';
    }
  }
}
