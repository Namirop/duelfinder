import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/participations/entities/participation.dart';
import 'package:tcg_matchmaker/features/participations/providers/participations_notifier.dart';
import 'package:tcg_matchmaker/shared/widgets/loading_widget.dart';

class GameRequestsSheet extends ConsumerStatefulWidget {
  final Game game;
  const GameRequestsSheet({super.key, required this.game});

  @override
  ConsumerState<GameRequestsSheet> createState() => _GameRequestsSheetState();
}

class _GameRequestsSheetState extends ConsumerState<GameRequestsSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(participationsNotifierProvider.notifier)
        .fetchGameParticipations(widget.game.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(participationsNotifierProvider);
    final pending = state.getPendingForGame(widget.game.id);
    final accepted = state.getAcceptedForGame(widget.game.id);

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
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, colorScheme),
                  const SizedBox(height: 24),
                  if (state.isLoadingGameParticipants)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: LoadingWidget(),
                    )
                  else if (state.getGameParticipantsError != null)
                    _buildError(
                        theme, colorScheme, state.getGameParticipantsError!)
                  else ...[
                    _buildPendingSection(theme, colorScheme, pending, state),
                    if (accepted.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildAcceptedSection(theme, colorScheme, accepted),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    final statusColor = widget.game.effectiveStatus.color;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.style_outlined, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.game.gameType.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _formatDate(widget.game.scheduledAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
          ),
          child: Text(
            '${widget.game.currentPlayers}/${widget.game.maxPlayers} joueurs',
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingSection(
    ThemeData theme,
    ColorScheme colorScheme,
    List<Participation> pending,
    dynamic state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          theme,
          colorScheme,
          'Demandes en attente',
          pending.length,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        if (pending.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Aucune demande en attente',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        else
          ...pending.map((p) => _buildRequestRow(
                theme,
                colorScheme,
                p,
                ref.watch(participationsNotifierProvider).isProcessing(p.id),
              )),
      ],
    );
  }

  Widget _buildAcceptedSection(
    ThemeData theme,
    ColorScheme colorScheme,
    List<Participation> accepted,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          theme,
          colorScheme,
          'Participants',
          accepted.length,
          Colors.green,
        ),
        const SizedBox(height: 12),
        ...accepted.map((p) => _buildParticipantRow(theme, colorScheme, p)),
      ],
    );
  }

  Widget _buildSectionTitle(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    int count,
    Color color,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestRow(
    ThemeData theme,
    ColorScheme colorScheme,
    Participation participation,
    bool isProcessing,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(participation.participant!.avatar),
            backgroundColor: colorScheme.primaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participation.participant!.username,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatRequestDate(participation.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (isProcessing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            _buildActionButton(
              icon: Icons.check_rounded,
              color: Colors.green,
              onTap: () => ref
                  .read(participationsNotifierProvider.notifier)
                  .acceptParticipation(participation.id, widget.game.id),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.close_rounded,
              color: Colors.red,
              onTap: () => ref
                  .read(participationsNotifierProvider.notifier)
                  .rejectParticipation(participation.id, widget.game.id),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantRow(
    ThemeData theme,
    ColorScheme colorScheme,
    Participation participation,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(participation.participant!.avatar),
            backgroundColor: colorScheme.primaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              participation.participant!.username,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildError(
    ThemeData theme,
    ColorScheme colorScheme,
    String error,
  ) {
    return Center(
      child: Column(
        children: [
          Text(error,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.error)),
          TextButton(
            onPressed: () => ref
                .read(participationsNotifierProvider.notifier)
                .fetchGameParticipations(widget.game.id),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE d MMM, HH:mm', 'fr_FR').format(date);
  }

  String _formatRequestDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }
}
