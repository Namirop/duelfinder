import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/games/entities/game_state.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_card.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation_state.dart';
import 'package:tcg_matchmaker/features/participations/providers/participations_notifier.dart';
import 'package:tcg_matchmaker/features/participations/widgets/participation_card.dart';
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
      // Les participations sont déjà chargées dans le build() du provider
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final gamesState = ref.watch(gamesNotifierProvider);
    final participationsState = ref.watch(participationsNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(theme, colorScheme, authState.user!.avatar),
            const SizedBox(height: 10),
            _buildTabBar(gamesState, participationsState),
            Expanded(
              child: _buildTabBarView(theme, gamesState, participationsState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
      ThemeData theme, ColorScheme colorScheme, String avatarUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: NetworkImage(avatarUrl),
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

  Widget _buildTabBar(
      GamesState gamesState, ParticipationsState participationsState) {
    return TabBar(
      overlayColor: WidgetStateColor.transparent,
      padding: const EdgeInsets.only(bottom: 10),
      tabs: [
        Tab(text: GameView.created.label(gamesState.myGames.length)),
        Tab(
            text: GameView.participations
                .label(participationsState.visibleParticipations.length)),
      ],
    );
  }

  Widget _buildTabBarView(ThemeData theme, GamesState gamesState,
      ParticipationsState participationsState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: TabBarView(
        children: [
          _buildGamesList(gamesState),
          _buildParticipationsList(participationsState),
        ],
      ),
    );
  }

  Widget _buildGamesList(GamesState state) {
    final theme = Theme.of(context);
    final games = state.myGames;

    if (state.isLoadingExisting && games.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorExisting != null && games.isEmpty) {
      return AppErrorWidget(
          message: state.errorExisting!,
          onRetry: () =>
              ref.read(gamesNotifierProvider.notifier).fetchCreatedGames());
    }

    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Aucune partie créée",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(navigationIndexProvider.notifier).state = 2,
              child: const Text("Créer une partie"),
            ),
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

  Widget _buildParticipationsList(ParticipationsState state) {
    final theme = Theme.of(context);
    final participations = state.visibleParticipations;

    if (state.isLoading && participations.isEmpty) {
      return const LoadingWidget();
    }

    if (state.error != null && participations.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref
            .read(participationsNotifierProvider.notifier)
            .fetchMyParticipations(),
      );
    }

    if (participations.isEmpty) {
      return Center(
        child: Text(
          "Aucune participation",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: participations.length,
      itemBuilder: (context, index) {
        return ParticipationCard(
          participation: participations[index],
          index: index,
        );
      },
    );
  }
}
