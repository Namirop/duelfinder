import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/enums/navigation_enum.dart';
import 'package:tcg_matchmaker/core/router/app_router.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/entities/game_enums.dart';
import 'package:tcg_matchmaker/features/games/entities/game_state.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/home/widgets/game_card.dart';
import 'package:tcg_matchmaker/features/notifications/widgets/notification_icon_button.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation.dart';
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
                final game = games[index];
                return GestureDetector(
                  onLongPress: () => _showGameActions(game),
                  child: GameCard(
                    game: game,
                    index: index,
                    showFullAddress: true,
                  ),
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

    if (state.error != null && participations.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
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
                final participation = participations[index];
                return GestureDetector(
                  onLongPress: () => _showParticipationActions(participation),
                  child: ParticipationCard(
                    participation: participation,
                    index: index,
                  ),
                );
              },
            ),
    );
  }

  void _showGameActions(Game game) {
    final isCancelled = game.effectiveStatus == GameStatus.CANCELLED;
    final isFinished = game.effectiveStatus == GameStatus.FINISHED;
    if (!isCancelled && !isFinished) return;

    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFinished)
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archiver'),
                onTap: () {
                  Navigator.pop(ctx);
                  _archiveGame(game.id);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: colorScheme.error),
              title: Text('Supprimer définitivement',
                  style: TextStyle(color: colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmPermanentDeleteGame(game.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _archiveGame(String gameId) async {
    await ref.read(gamesNotifierProvider.notifier).archiveGame(gameId);
    if (!mounted) return;
    final error = ref.read(gamesNotifierProvider).errorDeleting;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Partie archivée'),
        backgroundColor:
            error != null ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmPermanentDeleteGame(String gameId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer définitivement'),
        content: const Text(
            'Cette action est irréversible. La partie et toutes ses données seront supprimées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref.read(gamesNotifierProvider.notifier).permanentDeleteGame(gameId);
    if (!mounted) return;
    final error = ref.read(gamesNotifierProvider).errorDeleting;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Partie supprimée'),
        backgroundColor:
            error != null ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showParticipationActions(Participation participation) {
    final isCancelled = participation.isCancelled;
    final isRejected = participation.isRejected;
    final gameCancelled =
        participation.game?.effectiveStatus == GameStatus.CANCELLED;
    if (!isCancelled && !isRejected && !gameCancelled) return;

    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete_forever, color: colorScheme.error),
              title: Text('Supprimer définitivement',
                  style: TextStyle(color: colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmPermanentDeleteParticipation(participation.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPermanentDeleteParticipation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer définitivement'),
        content:
            const Text('Cette participation sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref
        .read(participationsNotifierProvider.notifier)
        .permanentDeleteParticipation(id);
    if (!mounted) return;
    final error = ref.read(participationsNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Participation supprimée'),
        backgroundColor:
            error != null ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
