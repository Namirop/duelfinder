import 'package:flutter/material.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';

class GameTypeBottomSheet extends StatefulWidget {
  final GameType? currentGameType;
  final ValueChanged<GameType?> onGameTypeSelected;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const GameTypeBottomSheet({
    super.key,
    required this.currentGameType,
    required this.onGameTypeSelected,
    required this.theme,
    required this.colorScheme,
  });

  @override
  State<GameTypeBottomSheet> createState() => _GameTypeBottomSheetState();
}

class _GameTypeBottomSheetState extends State<GameTypeBottomSheet> {
  GameType? _selectedGameType;

  @override
  void initState() {
    super.initState();
    _selectedGameType = widget.currentGameType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports_esports,
                      color: widget.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Type de jeu',
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Tous'),
                      selected: _selectedGameType == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedGameType = null);
                        }
                      },
                      selectedColor: widget.colorScheme.primaryContainer,
                      backgroundColor:
                          widget.colorScheme.surfaceContainerHighest,
                      labelStyle: widget.theme.textTheme.bodyMedium?.copyWith(
                        color: _selectedGameType == null
                            ? widget.colorScheme.onPrimaryContainer
                            : widget.colorScheme.onSurface,
                        fontWeight: _selectedGameType == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: _selectedGameType == null
                            ? widget.colorScheme.primary
                            : widget.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    ...GameType.values.map((type) {
                      final isSelected = _selectedGameType == type;
                      return ChoiceChip(
                        label: Text(type.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedGameType = type);
                          }
                        },
                        selectedColor: widget.colorScheme.primaryContainer,
                        backgroundColor:
                            widget.colorScheme.surfaceContainerHighest,
                        labelStyle: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? widget.colorScheme.onPrimaryContainer
                              : widget.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? widget.colorScheme.primary
                              : widget.colorScheme.outline
                                  .withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        widget.onGameTypeSelected(_selectedGameType),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.colorScheme.primary,
                      foregroundColor: widget.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Appliquer',
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
