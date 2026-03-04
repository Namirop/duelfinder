import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/models/create_game_model.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';

class CreateGameScreen extends ConsumerStatefulWidget {
  const CreateGameScreen({super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  GameType? _selectedGameType;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  int _maxPlayers = 4;
  int _duration = 60;
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createGame() async {
    final game = CreateGameModel(
        gameType: _selectedGameType!,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        address: _addressController.text,
        latitude: 50.20418040498222,
        longitude: 3.180598730339395,
        scheduledAt: DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, _selectedTime.hour, _selectedTime.minute),
        duration: _duration,
        maxPlayers: _maxPlayers);

    await ref.read(gamesNotifierProvider.notifier).createGame(game);

    final gamesState = ref.read(gamesNotifierProvider);

    if (gamesState.errorCreating != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(gamesNotifierProvider).errorCreating ??
                'Erreur lors de la création',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partie créée avec succès'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(theme, colorScheme),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(theme, "Type de jeu"),
                          const SizedBox(height: 12),
                          _buildGameTypeSelector(colorScheme, theme),
                          const SizedBox(height: 28),
                          _buildSectionTitle(theme, "Date et heure"),
                          const SizedBox(height: 12),
                          _buildDateTimeSelector(theme, colorScheme),
                          const SizedBox(height: 28),
                          _buildSectionTitle(theme, "Lieu"),
                          const SizedBox(height: 12),
                          _buildLocationField(theme, colorScheme),
                          const SizedBox(height: 28),
                          _buildSectionTitle(theme, "Joueurs"),
                          const SizedBox(height: 12),
                          _buildPlayersSelector(theme, colorScheme),
                          const SizedBox(height: 28),
                          _buildSectionTitle(theme, "Durée estimée"),
                          const SizedBox(height: 12),
                          _buildDurationSelector(theme, colorScheme),
                          const SizedBox(height: 28),
                          _buildSectionTitle(theme, "Description (optionnel)"),
                          const SizedBox(height: 12),
                          _buildDescriptionField(theme, colorScheme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: _buildCreateButton(theme, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // IconButton(
          //   onPressed: () => Navigator.of(context).pop(),
          //   icon: Icon(
          //     Icons.arrow_back_rounded,
          //     color: colorScheme.onSurface,
          //   ),
          // ),
          const SizedBox(width: 8),
          Text(
            "Créer une partie",
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 23),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildGameTypeSelector(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      children: GameType.values.map((type) {
        final isSelected = _selectedGameType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              onTap: () => setState(() => _selectedGameType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "TCG",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 1)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeSelector(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildSelectorCard(
            colorScheme: colorScheme,
            icon: Icons.calendar_today_rounded,
            label: _formatDate(_selectedDate),
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSelectorCard(
            colorScheme: colorScheme,
            icon: Icons.access_time_rounded,
            label: _selectedTime.format(context),
            onTap: _pickTime,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorCard({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _addressController,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: "Adresse ou lieu",
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.group_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Nombre max de joueurs",
              style: theme.textTheme.bodyMedium,
            ),
          ),
          _buildCounter(
            value: _maxPlayers,
            min: 2,
            max: 16,
            onChanged: (value) => setState(() => _maxPlayers = value),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector(ThemeData theme, ColorScheme colorScheme) {
    final durations = [30, 60, 90, 120, 180];

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: durations.map((duration) {
        final isSelected = _duration == duration;
        return GestureDetector(
          onTap: () => setState(() => _duration = duration),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              _formatDuration(duration),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCounter({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        _buildCounterButton(
          icon: Icons.remove_rounded,
          onTap: value > min ? () => onChanged(value - 1) : null,
          colorScheme: colorScheme,
        ),
        Container(
          width: 48,
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        _buildCounterButton(
          icon: Icons.add_rounded,
          onTap: value < max ? () => onChanged(value + 1) : null,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
    required ColorScheme colorScheme,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled
              ? colorScheme.onPrimary
              : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _descriptionController,
        style: theme.textTheme.bodyMedium,
        maxLines: 4,
        decoration: InputDecoration.collapsed(
          hintText: "Infos supplémentaires, règles...",
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme, ColorScheme colorScheme) {
    final isValid =
        _selectedGameType != null && _addressController.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3D4070), Color(0xFF2A2D4E)],
              stops: [0.0, 0.7],
            ),
            color: isValid ? null : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: isValid ? 0.35 : 0.1),
              width: 1,
            ),
          ),
          child: ElevatedButton(
            onPressed: isValid ? _createGame : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "Créer la partie",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isValid
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return "Aujourd'hui";
    } else if (dateOnly == tomorrow) {
      return "Demain";
    }

    const months = [
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sep',
      'oct',
      'nov',
      'déc'
    ];
    return "${date.day} ${months[date.month - 1]}";
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return "${minutes}min";
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return "${hours}h";
    return "${hours}h$mins";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }
}
