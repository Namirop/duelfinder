import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:tcg_matchmaker/core/constants/app_constants.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/models/create_game_model.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modèle de suggestion d'adresse
// ─────────────────────────────────────────────────────────────────────────────
class _AddressSuggestion {
  final String displayName;
  final double lat;
  final double lon;
  final String? road;
  final String? houseNumber;
  final String? city;

  const _AddressSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.road,
    this.houseNumber,
    this.city,
  });

  factory _AddressSuggestion.fromJson(Map<String, dynamic> json) {
    final addr = json['address'] as Map<String, dynamic>?;
    return _AddressSuggestion(
      displayName: json['display_name'] as String,
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
      road: addr?['road'] as String?,
      houseNumber: addr?['house_number'] as String?,
      city: (addr?['city'] ?? addr?['town'] ?? addr?['village'] ??
          addr?['municipality']) as String?,
    );
  }

  /// Libellé structuré: "Boulevard Audent 12, Charleroi"
  String get shortLabel {
    if (road != null) {
      final streetPart =
          houseNumber != null ? '$road $houseNumber' : road!;
      if (city != null) return '$streetPart, $city';
      return streetPart;
    }
    // Fallback: premiers éléments du display_name
    final parts = displayName.split(', ');
    if (parts.length <= 2) return displayName;
    return '${parts.first}, ${parts[1]}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget de recherche d'adresse avec autocomplete Nominatim
// ─────────────────────────────────────────────────────────────────────────────
class _AddressSearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<_AddressSuggestion> onSelected;

  const _AddressSearchField({
    required this.controller,
    required this.onSelected,
  });

  @override
  State<_AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<_AddressSearchField> {
  List<_AddressSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _showDropdown = false;
  bool _noStreetResults = false;
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _showDropdown = false);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
        _showDropdown = false;
        _noStreetResults = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '5',
        'addressdetails': '1',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'DuelFinder/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        final suggestions = data
            .map((e) => _AddressSuggestion.fromJson(e as Map<String, dynamic>))
            .where((s) => s.road != null)
            .toList();

        if (mounted) {
          final allResults = data
              .map((e) => _AddressSuggestion.fromJson(e as Map<String, dynamic>))
              .toList();
          setState(() {
            _suggestions = suggestions;
            _showDropdown = suggestions.isNotEmpty;
            _noStreetResults = suggestions.isEmpty && allResults.isNotEmpty;
            _isSearching = false;
          });
        }
      } else {
        if (mounted) setState(() => _isSearching = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: AppConstants.searchDebounceMs), () => _search(value));
  }

  void _selectSuggestion(_AddressSuggestion suggestion) {
    widget.controller.text = suggestion.shortLabel;
    widget.onSelected(suggestion);
    setState(() {
      _suggestions = [];
      _showDropdown = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
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
                  controller: widget.controller,
                  focusNode: _focusNode,
                  style: theme.textTheme.bodyMedium,
                  onChanged: _onChanged,
                  decoration: InputDecoration(
                    hintText: "Adresse ou lieu",
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_isSearching)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              if (!_isSearching && widget.controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    setState(() {
                      _suggestions = [];
                      _showDropdown = false;
                      _noStreetResults = false;
                    });
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
        ),
        if (_noStreetResults && !_showDropdown)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)),
                const SizedBox(width: 6),
                Text(
                  'Précisez une rue ou une adresse',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        if (_showDropdown && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _suggestions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final suggestion = entry.value;
                  return _SuggestionTile(
                    suggestion: suggestion,
                    isLast: i == _suggestions.length - 1,
                    onTap: () => _selectSuggestion(suggestion),
                    colorScheme: colorScheme,
                    theme: theme,
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class _SuggestionTile extends StatefulWidget {
  final _AddressSuggestion suggestion;
  final bool isLast;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _SuggestionTile({
    required this.suggestion,
    required this.isLast,
    required this.onTap,
    required this.colorScheme,
    required this.theme,
  });

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hovered
            ? widget.colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.place_rounded,
                    size: 18,
                    color:
                        widget.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.suggestion.shortLabel,
                          style: widget.theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.suggestion.displayName,
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: widget.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.isLast)
              Divider(
                height: 1,
                thickness: 1,
                indent: 42,
                color:
                    widget.colorScheme.outline.withValues(alpha: 0.15),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Écran de création de partie
// ─────────────────────────────────────────────────────────────────────────────
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

  double? _selectedLat;
  double? _selectedLon;

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
        latitude: _selectedLat!,
        longitude: _selectedLon!,
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
    final hasOpenGame = ref.watch(
        gamesNotifierProvider.select((s) => s.hasOpenGame));

    if (hasOpenGame) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme, colorScheme),
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Vous avez déjà une partie ouverte.\nComplétez-la ou annulez-la pour en créer une autre.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 95),
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
                          _AddressSearchField(
                            controller: _addressController,
                            onSelected: (suggestion) {
                              setState(() {
                                _selectedLat = suggestion.lat;
                                _selectedLon = suggestion.lon;
                              });
                            },
                          ),
                          if (_selectedLat != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 13,
                                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Lieu exact partagé après acceptation',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 28),
                          _buildSectionTitle(theme, "Joueurs"),
                          const SizedBox(height: 12),
                          _buildPlayersSelector(theme, colorScheme),
                          const SizedBox(height: 28),
                          _buildSectionTitle(theme, "Durée estimée"),
                          const SizedBox(height: 12),
                          _buildDurationSelector(theme, colorScheme),
                          const SizedBox(height: 28),
                          _buildSectionTitle(
                              theme, "Description (optionnel)"),
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
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.surface.withValues(alpha: 0),
                        colorScheme.surface,
                      ],
                      stops: const [0.0, 0.35],
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildCreateButton(theme, colorScheme),
                ),
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: colorScheme.onSurface,
            ),
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedGameType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  type.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
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
            Icon(icon, size: 20, color: colorScheme.primary),
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
          Icon(Icons.group_rounded, color: colorScheme.primary),
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
    final durations = AppConstants.gameDurationOptions;

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: durations.map((duration) {
        final isSelected = _duration == duration;
        return GestureDetector(
          onTap: () => setState(() => _duration = duration),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        color:
                            colorScheme.primary.withValues(alpha: 0.25),
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
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
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
          hintText: "Infos supplémentaires, duel, échange de cartes, test de deck, règles…",
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme, ColorScheme colorScheme) {
    final isValid = _selectedGameType != null &&
        _addressController.text.isNotEmpty &&
        _selectedLat != null &&
        _selectedLon != null;
    final isCreating = ref.watch(
        gamesNotifierProvider.select((s) => s.isCreating));
    final enabled = isValid && !isCreating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
        onTap: enabled ? _createGame : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      colorScheme.primary,
                      Color.lerp(colorScheme.primary, Colors.white, 0.15)!,
                    ],
                  )
                : null,
            color: enabled ? null : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled
                  ? Colors.white.withValues(alpha: 0.2)
                  : colorScheme.outline.withValues(alpha: 0.15),
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCreating
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 20,
                        color: enabled
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Créer la partie",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: enabled
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                    ],
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
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }
}
