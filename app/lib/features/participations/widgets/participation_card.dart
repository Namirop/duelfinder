import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcg_matchmaker/core/theme/app_theme.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_details_sheet.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation.dart';

class ParticipationCard extends StatelessWidget {
  final Participation participation;
  final int index;

  const ParticipationCard({
    super.key,
    required this.participation,
    this.index = 0,
  });

  void _showGameDetails(BuildContext context) {
    if (participation.game == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GameDetailsSheet(game: participation.game!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = participation.game;
    if (game == null) return const SizedBox.shrink();

    final cardColor =
        index.isEven ? AppTheme.gameCardColor1 : AppTheme.gameCardColor2;
    final gameCancelled = game.effectiveStatus == GameStatus.CANCELLED;
    final borderColor = gameCancelled ? AppTheme.statusCancelled : participation.status.color;

    return GestureDetector(
      onTap: () => _showGameDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            left: BorderSide(color: borderColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: borderColor.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, game, gameCancelled: gameCancelled),
              const SizedBox(height: 14),
              _buildInfoBar(theme, game),
              const SizedBox(height: 12),
              _buildDetailRow(
                theme,
                icon: Icons.location_on_outlined,
                text: game.address,
              ),
              const SizedBox(height: 6),
              _buildDetailRow(
                theme,
                icon: Icons.schedule_outlined,
                text: _formatDate(game.scheduledAt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Game game, {required bool gameCancelled}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(game.creator.avatar),
          backgroundColor: theme.colorScheme.primaryContainer,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            game.creator.username,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildStatusChip(theme, gameCancelled: gameCancelled),
      ],
    );
  }

  Widget _buildStatusChip(ThemeData theme, {required bool gameCancelled}) {
    final color = gameCancelled ? AppTheme.statusCancelled : participation.status.color;
    final icon = gameCancelled ? Icons.block_rounded : participation.status.icon;
    final label = gameCancelled ? 'Annulée' : participation.status.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(ThemeData theme, Game game) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildInfoColumn(
            theme,
            label: 'Jeu',
            value: game.gameType.label,
            icon: Icons.style_outlined,
          ),
          _buildDivider(),
          _buildInfoColumn(
            theme,
            label: 'Durée',
            value: '${game.duration} min',
            icon: Icons.timer_outlined,
          ),
          _buildDivider(),
          _buildInfoColumn(
            theme,
            label: 'Joueurs',
            value: '${game.currentPlayers}/${game.maxPlayers}',
            icon: Icons.people_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildInfoColumn(
    ThemeData theme, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon,
              size: 16,
              color: theme.colorScheme.primary.withValues(alpha: 0.8)),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(7),
          ),
          child:
              Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.65)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm', 'fr_FR');
    final dateFormat = DateFormat('dd MMM', 'fr_FR');
    final time = timeFormat.format(dateTime);

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Aujourd'hui à $time";
    }

    final tomorrow = now.add(const Duration(days: 1));
    if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return "Demain à $time";
    }

    return "${dateFormat.format(dateTime)} à $time";
  }
}
