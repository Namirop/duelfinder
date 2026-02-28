import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/enums/view_mode.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/entities/game_state.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/home/widgets/distance_filter.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_card.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_details_sheet.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_map.dart';
import 'package:tcg_matchmaker/shared/widgets/app_error_widget.dart';
import 'package:tcg_matchmaker/shared/widgets/loading_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ViewMode _viewMode = ViewMode.list;

  void _onDistanceChanged(double distance) {
    ref.read(gamesNotifierProvider.notifier).setDistanceFilter(distance);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildAppBar(theme, colorScheme, ref, authState.user!.avatar),
          Expanded(
            child: _buildBody(
              theme,
              colorScheme,
              authState.user?.username ?? 'Utilisateur',
              gamesState,
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
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
            child: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: NetworkImage(
                avatarUrl,
              ),
            ),
          ),
          Text("Parties disponibles",
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 23)),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_outlined,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    ColorScheme colorScheme,
    String username,
    GamesState gamesState,
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
          Row(
            children: [
              DistanceFilter(
                currentDistance: gamesState.distanceFilter,
                onDistanceChanged: _onDistanceChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _viewMode == ViewMode.list
                ? _buildExistingGamesList(gamesState)
                : GameMap(
                    games: gamesState.existingGames,
                    onGameTap: _showGameDetails,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingGamesList(GamesState gamesState) {
    if (gamesState.isLoadingExisting) {
      return const LoadingWidget();
    }

    if (gamesState.errorExisting != null && gamesState.existingGames.isEmpty) {
      return AppErrorWidget(
        message: gamesState.errorExisting!,
        onRetry: () =>
            ref.read(gamesNotifierProvider.notifier).fetchExistingGames(),
      );
    }

    if (gamesState.existingGames.isEmpty) {
      return Center(
        child: Text(
          "Aucune partie disponible",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: gamesState.existingGames.length,
      itemBuilder: (context, index) {
        final game = gamesState.existingGames[index];
        return GameCard(game: game, index: index);
      },
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
