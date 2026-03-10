import 'package:flutter/material.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final double currentSchedule;
  final ValueChanged<double> onScheduleSelected;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const ScheduleBottomSheet({
    super.key,
    required this.currentSchedule,
    required this.onScheduleSelected,
    required this.theme,
    required this.colorScheme,
  });

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  late double _selectedSchedule;

  static const List<double> _options = [1, 3, 6, 12, 24, 48, 168];

  @override
  void initState() {
    super.initState();
    _selectedSchedule = widget.currentSchedule;
  }

  String _getLabel(double value) {
    if (value == 48) return '2 jours';
    if (value == 168) return '1 semaine';
    return '${value.toInt()}h';
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
                      Icons.schedule,
                      color: widget.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Horaire de recherche',
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Afficher les parties qui commencent dans :',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _options.map((value) {
                    final isSelected = _selectedSchedule == value;
                    return ChoiceChip(
                      label: Text(_getLabel(value)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedSchedule = value);
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
                            : widget.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        widget.onScheduleSelected(_selectedSchedule),
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
