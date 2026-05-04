import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/messages/entities/message.dart';
import 'package:tcg_matchmaker/features/messages/entities/messages_state.dart';
import 'package:tcg_matchmaker/features/messages/providers/messages_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _canSend = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesNotifierProvider.notifier).openChat(widget.conversationId);
    });
  }

  @override
  void deactivate() {
    // closeChat doit être appelé ici (pas dans dispose) car ref n'est
    // plus utilisable après que le widget soit disposé
    ref.read(messagesNotifierProvider.notifier).closeChat();
    super.deactivate();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(messagesNotifierProvider);
    final conversation = state.conversationFor(widget.conversationId);

    // Scroll vers le bas à chaque nouveau message
    ref.listen<MessagesState>(messagesNotifierProvider, (prev, next) {
      if (next.activeMessages.length > (prev?.activeMessages.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      appBar: _buildAppBar(theme, colorScheme, conversation),
      body: Column(
        children: [
          Expanded(
            child: state.isLoadingMessages && state.activeMessages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessages != null && state.activeMessages.isEmpty
                    ? Center(
                        child: Text(
                          'Impossible de charger les messages',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : state.activeMessages.isEmpty
                        ? _buildEmptyChat(theme, colorScheme)
                        : _buildMessageList(
                            state.activeMessages, theme, colorScheme),
          ),
          if (conversation?.isArchived == true)
            _buildArchivedBanner(theme, colorScheme)
          else
            _buildInputBar(theme, colorScheme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    ColorScheme colorScheme,
    Conversation? conversation,
  ) {
    final gameColor = colorScheme.primary;
    final title = conversation?.address ?? 'Conversation';
    final gameLabel = conversation?.gameType.label ?? '';
    final membersCount = (conversation?.participants.length ?? 0) + 1;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: gameColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gameLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: gameColor,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.people_outline,
                size: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 2),
              Text(
                '$membersCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildEmptyChat(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Text(
        'Soyez le premier à écrire un message !',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildMessageList(
    List<Message> messages,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final currentUserId = ref.read(authNotifierProvider).user?.id ?? '';

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.sender.id == currentUserId;
        final isFirst =
            index == 0 || messages[index - 1].sender.id != message.sender.id;
        final isLast = index == messages.length - 1 ||
            messages[index + 1].sender.id != message.sender.id;

        return _MessageBubble(
          message: message,
          isMe: isMe,
          isFirst: isFirst,
          isLast: isLast,
        );
      },
    );
  }

  Widget _buildInputBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              onChanged: (v) => setState(() => _canSend = v.trim().isNotEmpty),
              style: theme.textTheme.bodyMedium,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (_canSend && !_isSending)
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
            ),
            child: _isSending
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: _canSend
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    onPressed: _canSend ? _handleSend : null,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedBanner(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 6),
          Text(
            'Partie terminée — conversation archivée',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _isSending) return;

    _inputController.clear();
    setState(() {
      _canSend = false;
      _isSending = true;
    });

    try {
      await ref.read(messagesNotifierProvider.notifier).sendMessage(content);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de l'envoi"),
            backgroundColor: Colors.red,
          ),
        );
        _inputController.text = content;
        setState(() => _canSend = true);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }
}

// ─── Message Bubble ──────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isFirst;
  final bool isLast;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bubbleColor =
        isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final textColor = isMe ? colorScheme.onPrimary : colorScheme.onSurface;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : (isLast ? 4 : 18)),
      bottomRight: Radius.circular(isMe ? (isLast ? 4 : 18) : 18),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 8 : 2,
        bottom: isLast ? 2 : 0,
        left: isMe ? 52 : 0,
        right: isMe ? 0 : 52,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            if (isLast)
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(message.sender.avatar),
                backgroundColor: colorScheme.primaryContainer,
                onBackgroundImageError: (_, __) {},
                child: message.sender.avatar.isEmpty
                    ? Text(
                        message.sender.username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && isFirst)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      message.sender.username,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                  ),
                  child: Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      height: 1.35,
                    ),
                  ),
                ),
                if (isLast)
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                    child: Text(
                      _formatTime(message.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.35),
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
