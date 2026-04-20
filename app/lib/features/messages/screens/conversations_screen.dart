import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_matchmaker/core/router/app_router.dart';
import 'package:tcg_matchmaker/features/messages/entities/message.dart';
import 'package:tcg_matchmaker/features/messages/providers/messages_provider.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(messagesNotifierProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Messages',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 23),
            ),
          ),
          Expanded(
            child: state.isLoadingConversations && state.conversations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.errorConversations != null &&
                        state.conversations.isEmpty
                    ? _buildError(theme, colorScheme, ref)
                    : _buildList(
                        context,
                        ref,
                        theme,
                        colorScheme,
                        state.conversations,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
    List<Conversation> conversations,
  ) {
    final active = conversations.where((c) => !c.isArchived).toList();
    final archived = conversations.where((c) => c.isArchived).toList();

    if (conversations.isEmpty) return _buildEmpty(theme, colorScheme);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(messagesNotifierProvider.notifier).fetchConversations(),
      child: _ConversationList(active: active, archived: archived),
    );
  }

  Widget _buildEmpty(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 56,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune conversation',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rejoins une partie pour commencer à discuter',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, ColorScheme colorScheme, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Impossible de charger les conversations',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => ref
                .read(messagesNotifierProvider.notifier)
                .fetchConversations(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// ─── Liste avec section archives ─────────────────────────────────────────────

class _ConversationList extends ConsumerStatefulWidget {
  final List<Conversation> active;
  final List<Conversation> archived;

  const _ConversationList({required this.active, required this.archived});

  @override
  ConsumerState<_ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends ConsumerState<_ConversationList> {
  bool _archiveExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        ...widget.active.map(
          (conv) => _ConversationTile(
            conversation: conv,
            onTap: () => context.push(
              AppRoutes.conversation.replaceFirst(':id', conv.gameId),
            ),
          ),
        ),
        if (widget.archived.isNotEmpty) ...[
          InkWell(
            onTap: () =>
                setState(() => _archiveExpanded = !_archiveExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Archives (${widget.archived.length})',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _archiveExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
          ),
          if (_archiveExpanded)
            ...widget.archived.map(
              (conv) => _ConversationTile(
                conversation: conv,
                onTap: () => context.push(
                  AppRoutes.conversation.replaceFirst(':id', conv.gameId),
                ),
                onLongPress: () => _confirmHideConversation(conv, colorScheme),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _confirmHideConversation(
      Conversation conv, ColorScheme colorScheme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text(
            'Cette conversation archivée sera retirée de votre liste.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(messagesNotifierProvider.notifier)
          .hideConversation(conv.gameId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation supprimée'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de la suppression'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ─── Conversation Tile ───────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasUnread = conversation.unreadCount > 0;
    final isArchived = conversation.isArchived;
    final gameColor = isArchived
        ? colorScheme.onSurface.withValues(alpha: 0.35)
        : colorScheme.primary;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
        ),
        child: Row(
          children: [
            _buildGameAvatar(gameColor, isArchived, conversation),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _title(conversation),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isArchived
                                ? colorScheme.onSurface
                                    .withValues(alpha: 0.5)
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (conversation.lastMessage != null)
                        Text(
                          _timeAgo(conversation.lastMessage!.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: hasUnread
                                ? colorScheme.primary
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _lastMessagePreview(conversation),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasUnread
                                ? colorScheme.onSurface
                                    .withValues(alpha: 0.85)
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        _buildUnreadBadge(colorScheme),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildGameTypeBadge(theme, gameColor, isArchived),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(Conversation c) {
    return c.address;
  }

  String _lastMessagePreview(Conversation c) {
    if (c.lastMessage == null) return 'Aucun message';
    return '${c.lastMessage!.senderUsername} : ${c.lastMessage!.content}';
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    if (diff.inDays < 7) return '${diff.inDays} j';
    return '${date.day}/${date.month}';
  }

  Widget _buildGameAvatar(
      Color gameColor, bool isArchived, Conversation conv) {
    final totalMembers = conv.participants.length + 1;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: gameColor.withValues(alpha: isArchived ? 0.08 : 0.15),
            border: Border.all(
              color: gameColor.withValues(alpha: isArchived ? 0.2 : 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              conv.gameType.shortLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: gameColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF232340),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: gameColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 9,
                  color: gameColor.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 2),
                Text(
                  '$totalMembers',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: gameColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameTypeBadge(
      ThemeData theme, Color gameColor, bool isArchived) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: gameColor.withValues(alpha: isArchived ? 0.06 : 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            conversation.gameType.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: gameColor.withValues(alpha: isArchived ? 0.5 : 0.9),
              fontSize: 10,
            ),
          ),
        ),
        if (isArchived) ...[
          const SizedBox(width: 6),
          Icon(
            Icons.lock_outline,
            size: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ],
      ],
    );
  }

  Widget _buildUnreadBadge(ColorScheme colorScheme) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${conversation.unreadCount}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
