import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/enums/navigation_enum.dart';
import 'package:tcg_matchmaker/core/router/app_router.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/games/entities/game_state.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_card.dart';
import 'package:tcg_matchmaker/features/notifications/widgets/notification_icon_button.dart';
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

// Pur écran d'affichage, ne gère pas de chargement initial, consomme juste le state
class _MyGamesScreenState extends ConsumerState<MyGamesScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final gamesState = ref.watch(gamesNotifierProvider);
    final participationsState = ref.watch(participationsNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<GamesState>(gamesNotifierProvider, (previous, next) {
      if (previous?.myGames != next.myGames) {
        for (final game in next.myGames) {
          ref
              .read(participationsNotifierProvider.notifier)
              .fetchGameParticipations(game.id);
        }
      }
    });

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(theme, colorScheme, authState.user?.avatar ?? ''),
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
          GestureDetector(
            onTap: () => ref.read(navigationIndexProvider.notifier).state =
                NavTab.profile.index,
            child: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: NetworkImage(avatarUrl),
            ),
          ),
          Text("Mes parties",
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 25)),
          NotificationIconButton(colorScheme: colorScheme),
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
    return TabBarView(
      children: [
        _buildGamesList(gamesState),
        _buildParticipationsList(participationsState),
      ],
    );
  }

  Widget _buildGamesList(GamesState state) {
    final theme = Theme.of(context);
    final games = state.myGames;

    if (state.isLoadingMyGames && games.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMyGames != null && games.isEmpty) {
      return AppErrorWidget(
          message: state.errorMyGames!,
          onRetry: () =>
              ref.read(gamesNotifierProvider.notifier).fetchCreatedGames());
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(gamesNotifierProvider.notifier).fetchCreatedGames(),
      child: games.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Aucune partie créée",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.createGame),
                          child: const Text("Créer une partie"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) {
                return GameCard(
                  game: games[index],
                  index: index,
                  showFullAddress: true,
                );
              },
            ),
    );
  }

  Widget _buildParticipationsList(ParticipationsState state) {
    final theme = Theme.of(context);
    final participations = state.visibleParticipations;

    if (state.isLoadingMyParticipations && participations.isEmpty) {
      return const LoadingWidget();
    }

    if (state.getMyParticipationsError != null && participations.isEmpty) {
      return AppErrorWidget(
        message: state.getMyParticipationsError!,
        onRetry: () => ref
            .read(participationsNotifierProvider.notifier)
            .fetchMyParticipations(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(participationsNotifierProvider.notifier)
          .fetchMyParticipations(),
      child: participations.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      "Aucune participation",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              itemCount: participations.length,
              itemBuilder: (context, index) {
                return ParticipationCard(
                  participation: participations[index],
                  index: index,
                );
              },
            ),
    );
  }
}
