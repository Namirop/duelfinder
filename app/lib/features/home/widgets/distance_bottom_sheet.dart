import 'package:flutter/material.dart';

class DistanceBottomSheet extends StatefulWidget {
  final double currentDistance;
  final ValueChanged<double> onDistanceSelected;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const DistanceBottomSheet({
    super.key,
    required this.currentDistance,
    required this.onDistanceSelected,
    required this.theme,
    required this.colorScheme,
  });

  @override
  State<DistanceBottomSheet> createState() => _DistanceBottomSheetState();
}

class _DistanceBottomSheetState extends State<DistanceBottomSheet> {
  late double _selectedDistance;

  static const double _minDistance = 5;
  static const double _maxDistance = 100;

  @override
  void initState() {
    super.initState();
    _selectedDistance = widget.currentDistance;
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
                      Icons.near_me,
                      color: widget.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Distance de recherche',
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: widget.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_selectedDistance.toInt()} km',
                      style: widget.theme.textTheme.headlineMedium?.copyWith(
                        color: widget.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: widget.colorScheme.primary,
                    inactiveTrackColor:
                        widget.colorScheme.primary.withValues(alpha: 0.2),
                    thumbColor: widget.colorScheme.primary,
                    overlayColor:
                        widget.colorScheme.primary.withValues(alpha: 0.2),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: _selectedDistance,
                    min: _minDistance,
                    max: _maxDistance,
                    divisions: ((_maxDistance - _minDistance) / 5).toInt(),
                    onChanged: (value) {
                      setState(() => _selectedDistance = value);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_minDistance.toInt()} km',
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        '${_maxDistance.toInt()} km',
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        widget.onDistanceSelected(_selectedDistance),
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
