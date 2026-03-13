import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcg_matchmaker/features/games/entities/game_state.dart';

class ScheduleFilter extends StatelessWidget {
  final ScheduleFilterOption currentOption;
  final DateTime? customDate;
  final void Function(ScheduleFilterOption option, {DateTime? customDate})
      onScheduleChanged;

  const ScheduleFilter({
    super.key,
    required this.currentOption,
    required this.onScheduleChanged,
    this.customDate,
  });

  String _getLabel() {
    if (currentOption == ScheduleFilterOption.custom && customDate != null) {
      return DateFormat('d MMM', 'fr_FR').format(customDate!);
    }
    return currentOption.label;
  }

  void _showSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScheduleBottomSheet(
        currentOption: currentOption,
        customDate: customDate,
        onSelected: (option, {DateTime? custom}) {
          onScheduleChanged(option, customDate: custom);
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
    final isActive = currentOption != ScheduleFilterOption.all;

    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: isActive ? colorScheme.primary : colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              _getLabel(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: isActive
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
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

class _ScheduleBottomSheet extends StatefulWidget {
  final ScheduleFilterOption currentOption;
  final DateTime? customDate;
  final void Function(ScheduleFilterOption option, {DateTime? custom}) onSelected;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ScheduleBottomSheet({
    required this.currentOption,
    required this.onSelected,
    required this.theme,
    required this.colorScheme,
    this.customDate,
  });

  @override
  State<_ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<_ScheduleBottomSheet> {
  late ScheduleFilterOption _selected;
  DateTime? _customDate;

  static const _presets = [
    ScheduleFilterOption.all,
    ScheduleFilterOption.today,
    ScheduleFilterOption.tomorrow,
    ScheduleFilterOption.thisWeek,
    ScheduleFilterOption.custom,
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentOption;
    _customDate = widget.customDate;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selected = ScheduleFilterOption.custom;
        _customDate = picked;
      });
    }
  }

  String _labelFor(ScheduleFilterOption opt) {
    if (opt == ScheduleFilterOption.custom && _customDate != null) {
      return DateFormat('d MMM yyyy', 'fr_FR').format(_customDate!);
    }
    return opt.label;
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
                      Icons.calendar_today_outlined,
                      color: widget.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Date de la partie :',
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
                  children: _presets.map((opt) {
                    final isSelected = _selected == opt;
                    final isCustom = opt == ScheduleFilterOption.custom;

                    return GestureDetector(
                      onTap: () async {
                        if (isCustom) {
                          await _pickDate();
                        } else {
                          setState(() {
                            _selected = opt;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.colorScheme.primaryContainer
                              : widget.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? widget.colorScheme.primary
                                : widget.colorScheme.outline
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCustom)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.edit_calendar_outlined,
                                  size: 16,
                                  color: isSelected
                                      ? widget.colorScheme.onPrimaryContainer
                                      : widget.colorScheme.onSurface,
                                ),
                              ),
                            Text(
                              _labelFor(opt),
                              style: widget.theme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: isSelected
                                    ? widget.colorScheme.onPrimaryContainer
                                    : widget.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.onSelected(
                      _selected,
                      custom: _selected == ScheduleFilterOption.custom
                          ? _customDate
                          : null,
                    ),
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
