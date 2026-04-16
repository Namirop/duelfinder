import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/games/widgets/game_requests_sheet.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation.dart';
import 'package:tcg_matchmaker/features/participations/providers/participations_notifier.dart';

class GameDetailsSheet extends ConsumerWidget {
  final Game game;

  const GameDetailsSheet({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme, colorScheme),
                const SizedBox(height: 20),
                _buildGameType(theme, colorScheme),
                const SizedBox(height: 16),
                _buildDateTime(theme, colorScheme),
                const SizedBox(height: 12),
                _buildLocation(theme, colorScheme, ref),
                const SizedBox(height: 12),
                _buildPlayers(theme, colorScheme),
                const SizedBox(height: 12),
                if (game.description != null && game.description!.isNotEmpty)
                  _buildDescription(theme, colorScheme),
                const SizedBox(height: 24),
                _buildJoinButton(context, ref, theme, colorScheme),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    final statusColor = game.effectiveStatus.color;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: statusColor,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(game.creator.avatar),
            backgroundColor: colorScheme.primaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.creator.username,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  game.effectiveStatus.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameType(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.style_outlined,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            game.gameType.label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTime(ThemeData theme, ColorScheme colorScheme) {
    final dateFormat = DateFormat('EEEE d MMMM', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(game.scheduledAt),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${timeFormat.format(game.scheduledAt)} - ${timeFormat.format(game.endTime)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(
      ThemeData theme, ColorScheme colorScheme, WidgetRef ref) {
    final currentUserId = ref.watch(authNotifierProvider).user?.id;
    final isCreator = currentUserId == game.creator.id;
    final existingParticipation = ref
        .read(participationsNotifierProvider.notifier)
        .getParticipationForGame(game.id);
    final isAccepted = existingParticipation?.isAccepted ?? false;
    final showFullAddress = isCreator || isAccepted;

    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: showFullAddress
              ? Text(
                  game.address,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.streetOnly,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lieu exact après acceptation',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPlayers(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_outline,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              '${game.currentPlayers}/${game.maxPlayers} joueurs',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildParticipantAvatars(theme, colorScheme),
      ],
    );
  }

  Widget _buildParticipantAvatars(ThemeData theme, ColorScheme colorScheme) {
    final allPlayers = [game.creator, ...game.participants];

    return Row(
      children: [
        SizedBox(
          width: allPlayers.length * 28.0 + 12,
          height: 40,
          child: Stack(
            children: [
              for (var i = 0; i < allPlayers.length; i++)
                Positioned(
                  left: i * 28.0,
                  child: Tooltip(
                    message: i == 0
                        ? '${allPlayers[i].username} (hôte)'
                        : allPlayers[i].username,
                    preferBelow: false,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onInverseSurface,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.inverseSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i == 0
                              ? colorScheme.primary
                              : colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(allPlayers[i].avatar),
                        backgroundColor: colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'Description',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          game.description!,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildJoinButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final authState = ref.watch(authNotifierProvider);
    final participationsState = ref.watch(participationsNotifierProvider);
    final currentUserId = authState.user?.id;

    // Vérifier si c'est la partie de l'utilisateur
    final isCreator = currentUserId == game.creator.id;
    if (isCreator) {
      return _buildCreatorButton(context, ref, theme, colorScheme);
    }

    // Vérifier si l'utilisateur a déjà une participation
    final existingParticipation = ref
        .read(participationsNotifierProvider.notifier)
        .getParticipationForGame(game.id);

    // Si une participation existe, afficher le statut approprié
    if (existingParticipation != null) {
      return _buildParticipationStatusButton(
        context,
        ref,
        theme,
        colorScheme,
        existingParticipation,
        participationsState.isRequesting,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            game.effectiveStatus.canJoin && !participationsState.isRequesting
                ? () => _handleJoinRequest(context, ref)
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: participationsState.isRequesting
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : Text(
                game.effectiveStatus.canJoin
                    ? 'Demander à rejoindre'
                    : game.effectiveStatus.disabledButtonText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: game.effectiveStatus.canJoin
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
      ),
    );
  }

  Widget _buildCreatorButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isCancellable = game.effectiveStatus == GameStatus.OPEN ||
        game.effectiveStatus == GameStatus.FULL;
    final showManageRequests = isCancellable && game.pendingCount > 0;

    return Column(
      children: [
        if (showManageRequests)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => GameRequestsSheet(game: game),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.people_outline),
              label: Text(
                'Gérer les demandes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        if (isCancellable) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleCancelGame(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.cancel_outlined, size: 20),
              label: Text(
                'Annuler la partie',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleCancelGame(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la partie'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette partie ? Les participants seront notifiés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Annuler la partie'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(gamesNotifierProvider.notifier).cancelGame(game.id);

    if (!context.mounted) return;

    final error = ref.read(gamesNotifierProvider).errorDeleting;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partie annulée'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildParticipationStatusButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
    Participation participation,
    bool isRequesting,
  ) {
    final isGameOver = game.effectiveStatus == GameStatus.IN_PROGRESS ||
        game.effectiveStatus == GameStatus.FINISHED ||
        game.effectiveStatus == GameStatus.CANCELLED;

    switch (participation.status) {
      case ParticipationStatus.PENDING:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isRequesting
                ? null
                : () => _handleCancelParticipation(context, ref, participation),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isRequesting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_top,
                          size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Demande en attente',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
          ),
        );

      case ParticipationStatus.ACCEPTED:
        final isFinished = game.effectiveStatus == GameStatus.FINISHED;
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isRequesting || isGameOver
                ? null
                : () => _handleCancelParticipation(context, ref, participation),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: BorderSide(
                color: isGameOver
                    ? colorScheme.onSurface.withValues(alpha: 0.2)
                    : Colors.green,
              ),
              disabledForegroundColor:
                  colorScheme.onSurface.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isRequesting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFinished ? Icons.event_available : Icons.check_circle,
                        size: 20,
                        color: isGameOver
                            ? colorScheme.onSurface.withValues(alpha: 0.4)
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFinished ? 'Vous avez participé' : 'Vous participez',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isGameOver
                              ? colorScheme.onSurface.withValues(alpha: 0.4)
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
          ),
        );

      case ParticipationStatus.REJECTED:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              disabledForegroundColor:
                  colorScheme.onSurface.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cancel,
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 8),
                Text(
                  'Demande refusée',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        );

      case ParticipationStatus.CANCELLED:
        final canJoin = game.effectiveStatus.canJoin;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canJoin && !isRequesting
                ? () => _handleJoinRequest(context, ref)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              disabledForegroundColor:
                  colorScheme.onSurface.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isRequesting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    canJoin
                        ? 'Redemander à rejoindre'
                        : game.effectiveStatus.disabledButtonText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: canJoin
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
          ),
        );
    }
  }

  Future<void> _handleJoinRequest(BuildContext context, WidgetRef ref) async {
    await ref
        .read(participationsNotifierProvider.notifier)
        .requestToJoin(game.id, game);

    if (!context.mounted) return;

    final error =
        ref.read(participationsNotifierProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande envoyée !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleCancelParticipation(
    BuildContext context,
    WidgetRef ref,
    Participation participation,
  ) async {
    // Demander confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la participation'),
        content: Text(
          participation.isAccepted
              ? 'Êtes-vous sûr de vouloir quitter cette partie ?'
              : 'Êtes-vous sûr de vouloir annuler votre demande ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref
        .read(participationsNotifierProvider.notifier)
        .cancelParticipation(participation.id);

    if (!context.mounted) return;

    final error =
        ref.read(participationsNotifierProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            participation.isAccepted
                ? 'Vous avez quitté la partie'
                : 'Demande annulée',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
