import 'package:flutter/material.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/home/widgets/filters/game_type_bottom_sheet.dart';

class GameTypeFilter extends StatelessWidget {
  final GameType? currentGameType;
  final ValueChanged<GameType?> onGameTypeChanged;

  const GameTypeFilter({
    super.key,
    required this.currentGameType,
    required this.onGameTypeChanged,
  });

  void _showGameTypeSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GameTypeBottomSheet(
        currentGameType: currentGameType,
        onGameTypeSelected: (gameType) {
          onGameTypeChanged(gameType);
          Navigator.pop(context);
        },
        theme: theme,
        colorScheme: colorScheme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _showGameTypeSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              currentGameType?.label ?? 'Tous',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
