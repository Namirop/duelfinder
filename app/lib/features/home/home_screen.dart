import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/enums/navigation_enum.dart';
import 'package:tcg_matchmaker/core/enums/view_mode.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/entities/game_state.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/profile/providers/settings_provider.dart';
import 'package:tcg_matchmaker/features/home/widgets/filters/distance_filter.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_card.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_details_sheet.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_map.dart';
import 'package:tcg_matchmaker/features/home/widgets/filters/game_type_filter.dart';
import 'package:tcg_matchmaker/features/home/widgets/filters/schedule_filter.dart';
import 'package:tcg_matchmaker/features/notifications/widgets/notification_icon_button.dart';
import 'package:tcg_matchmaker/shared/widgets/app_error_widget.dart';
import 'package:tcg_matchmaker/shared/widgets/loading_widget.dart';
import 'package:tcg_matchmaker/shared/widgets/no_localization_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ViewMode _viewMode = ViewMode.map;

  void _onDistanceChanged(double distance) {
    ref.read(gamesNotifierProvider.notifier).setDistanceFilter(distance);
  }

  void _onScheduleChanged(ScheduleFilterOption option, {DateTime? customDate}) {
    ref
        .read(gamesNotifierProvider.notifier)
        .setScheduleFilter(option, customDate: customDate);
  }

  void _onGameTypeChanged(GameType? gameType) {
    ref.read(gamesNotifierProvider.notifier).setGameTypeFilter(gameType);
  }

  void _onResetFilters() {
    ref.read(gamesNotifierProvider.notifier).resetFilters();
  }

  void _showGameDetails(Game game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GameDetailsSheet(game: game),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final gamesState = ref.watch(gamesNotifierProvider);
    final locationEnabled = ref.watch(settingsNotifierProvider).locationEnabled;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildAppBar(theme, colorScheme, ref, authState.user?.avatar ?? ''),
          Expanded(
            child: _buildBody(
              theme,
              colorScheme,
              authState.user?.username ?? 'Utilisateur',
              gamesState,
              locationEnabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, ColorScheme colorScheme, WidgetRef ref,
      String avatarUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => ref.read(navigationIndexProvider.notifier).state =
                NavTab.profile.index,
            child: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: NetworkImage(
                avatarUrl,
              ),
            ),
          ),
          Text("Parties disponibles",
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 23)),
          NotificationIconButton(colorScheme: colorScheme),
        ],
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    ColorScheme colorScheme,
    String username,
    GamesState gamesState,
    bool locationEnabled,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bonjour, $username.",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
              _buildToggle(theme, colorScheme),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DistanceFilter(
                  currentDistance: gamesState.distanceFilter,
                  onDistanceChanged: _onDistanceChanged,
                ),
                const SizedBox(width: 8),
                ScheduleFilter(
                  currentOption: gamesState.scheduleOption,
                  customDate: gamesState.customScheduleDate,
                  onScheduleChanged: _onScheduleChanged,
                ),
                const SizedBox(width: 8),
                GameTypeFilter(
                  currentGameType: gamesState.gameTypeFilter,
                  onGameTypeChanged: _onGameTypeChanged,
                ),
                const SizedBox(width: 8),
                _buildResetButton(colorScheme),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: !locationEnabled
                ? const NoLocalizationWidget()
                : IndexedStack(
                    index: _viewMode == ViewMode.list ? 0 : 1,
                    children: [
                      _buildExistingGamesList(gamesState),
                      _buildMapWithRefresh(gamesState),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingGamesList(GamesState gamesState) {
    if (gamesState.isLoadingExisting && gamesState.existingGames.isEmpty) {
      return const LoadingWidget();
    }

    if (gamesState.errorExisting != null && gamesState.existingGames.isEmpty) {
      return AppErrorWidget(
        message: gamesState.errorExisting!,
        onRetry: () =>
            ref.read(gamesNotifierProvider.notifier).fetchExistingGames(),
      );
    }

    final games = gamesState.visibleGames;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(gamesNotifierProvider.notifier).fetchExistingGames(),
      child: games.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      "Aucune partie disponible",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return GameCard(game: game, index: index);
              },
            ),
    );
  }

  Widget _buildMapWithRefresh(GamesState gamesState) {
    return GameMap(
      key: const ValueKey('map'),
      games: gamesState.visibleGames,
      myGames: gamesState.myGames,
      onGameTap: _showGameDetails,
      distanceKm: gamesState.distanceFilter,
      isRefreshing: gamesState.isLoadingExisting,
      onRefresh: gamesState.isLoadingExisting
          ? null
          : () =>
              ref.read(gamesNotifierProvider.notifier).fetchExistingGames(),
    );
  }

  Widget _buildResetButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _onResetFilters,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.highlight_remove,
          size: 18,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildToggle(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedToggleSwitch<ViewMode>.dual(
      current: _viewMode,
      first: ViewMode.list,
      second: ViewMode.map,
      onChanged: (value) => setState(() => _viewMode = value),
      styleBuilder: (value) => ToggleStyle(
        indicatorColor: colorScheme.primary,
        borderColor: Colors.transparent,
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      height: 32,
      indicatorSize: const Size.fromWidth(32),
      iconBuilder: (value) => Icon(
        value == ViewMode.list ? Icons.list : Icons.map,
        color: colorScheme.onPrimary,
        size: 16,
      ),
      textBuilder: (value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          value == ViewMode.list ? ViewMode.list.label() : ViewMode.map.label(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
