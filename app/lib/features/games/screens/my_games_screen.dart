import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/entities/game_state.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_card.dart';
import 'package:tcg_matchmaker/shared/widgets/app_error_widget.dart';
import 'package:tcg_matchmaker/shared/widgets/loading_widget.dart';

class MyGamesScreen extends ConsumerStatefulWidget {
  const MyGamesScreen({super.key});

  @override
  ConsumerState<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends ConsumerState<MyGamesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gamesNotifierProvider.notifier).fetchCreatedGames();
      ref.read(gamesNotifierProvider.notifier).fetchJoinedGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamesState = ref.watch(gamesNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(theme, colorScheme),
            const SizedBox(
              height: 10,
            ),
            _buildTabBar(gamesState),
            Expanded(child: _buildTabBarView(theme, gamesState)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: const NetworkImage(
              "https://api.dicebear.com/7.x/avataaars/png?seed=jbcoso",
            ),
          ),
          Text("Mes parties",
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 25)),
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

  Widget _buildTabBar(GamesState gamesState) {
    return TabBar(
      overlayColor: WidgetStateColor.transparent,
      padding: const EdgeInsets.only(bottom: 10),
      tabs: [
        Tab(text: GameView.created.label(gamesState.myGames.length)),
        Tab(text: GameView.joined.label(gamesState.joinedGames.length)),
      ],
    );
  }

  Widget _buildTabBarView(ThemeData theme, GamesState gamesState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: TabBarView(
        children: [
          _buildGamesList(
            games: gamesState.myGames,
            isLoading: gamesState.isLoadingMyGames,
            error: gamesState.errorMyGames,
            onRetry: () =>
                ref.read(gamesNotifierProvider.notifier).fetchCreatedGames(),
            emptyMessage: "Aucune partie créée",
            emptyAction: TextButton(
              onPressed: () => context.push('/games/create'),
              child: const Text("Créer une partie"),
            ),
          ),
          _buildGamesList(
            games: gamesState.joinedGames,
            isLoading: gamesState.isLoadingJoined,
            error: gamesState.errorJoined,
            onRetry: () =>
                ref.read(gamesNotifierProvider.notifier).fetchJoinedGames(),
            emptyMessage: "Aucune partie rejointe",
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList({
    required List<Game> games,
    required bool isLoading,
    required String? error,
    required VoidCallback onRetry,
    required String emptyMessage,
    Widget? emptyAction,
  }) {
    final theme = Theme.of(context);

    if (isLoading && games.isEmpty) {
      return const LoadingWidget();
    }

    if (error != null && games.isEmpty) {
      return AppErrorWidget(message: error, onRetry: onRetry);
    }

    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emptyMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (emptyAction != null) ...[
              const SizedBox(height: 8),
              emptyAction,
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return GameCard(game: games[index], index: index);
      },
    );
  }
}
