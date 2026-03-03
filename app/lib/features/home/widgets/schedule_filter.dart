import 'package:flutter/material.dart';
import 'package:tcg_matchmaker/features/home/widgets/schedule_bottom_sheet.dart';

class ScheduleFilter extends StatelessWidget {
  final double currentSchedule;
  final ValueChanged<double> onScheduleChanged;
  const ScheduleFilter({
    super.key,
    required this.currentSchedule,
    required this.onScheduleChanged,
  });

  String _getLabel(double value) {
    if (value == 48) return '2 jours';
    if (value == 168) return '1 semaine';
    return '${value.toInt()}h';
  }

  void _showScheduleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleBottomSheet(
        currentSchedule: currentSchedule,
        onScheduleSelected: (schedule) {
          onScheduleChanged(schedule);
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
      onTap: () => _showScheduleSheet(context),
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
              Icons.schedule_outlined,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              _getLabel(currentSchedule),
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
