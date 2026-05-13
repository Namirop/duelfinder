import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/constants/app_constants.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/messages/entities/messages_state.dart';

part 'messages_provider.g.dart';

@Riverpod(keepAlive: true)
class MessagesNotifier extends _$MessagesNotifier {
  Timer? _pollingTimer;

  @override
  MessagesState build() {
    ref.onDispose(() => _pollingTimer?.cancel());
    return const MessagesState();
  }

  // ── Conversations ─────────────────────────────────────────────

  Future<void> fetchConversations() async {
    state = state.copyWith(
      isLoadingConversations: true,
      clearErrorConversations: true,
    );
    try {
      final conversations =
          await ref.read(messagesRepositoryProvider).getConversations();
      final totalUnread = conversations.fold(0, (sum, c) => sum + c.unreadCount);
      AppLogger.d('MessagesNotifier',
          'fetchConversations OK: ${conversations.length} convs, totalUnread=$totalUnread');
      state = state.copyWith(
        conversations: conversations,
        isLoadingConversations: false,
      );
    } on AppException catch (e) {
      AppLogger.w('MessagesNotifier', 'fetchConversations failed: $e');
      state = state.copyWith(
        errorConversations: e.message,
        isLoadingConversations: false,
      );
    } catch (e, st) {
      AppLogger.e('MessagesNotifier', 'fetchConversations failed', e, st);
      state = state.copyWith(
        errorConversations: 'Erreur inconnue',
        isLoadingConversations: false,
      );
    }
  }

  /// Called by the firebase handler when a NEW_MESSAGE push arrives.
  /// Optimistically increments unread count, then fetches from backend.
  void onNewMessagePush(String gameId) {
    AppLogger.d('MessagesNotifier',
        'onNewMessagePush gameId=${gameId.substring(0, 8)}, activeGameId=${state.activeGameId?.substring(0, 8)}, convCount=${state.conversations.length}');

    // If user is viewing this chat, polling handles messages — skip optimistic update
    if (state.activeGameId != gameId) {
      // Optimistic local update: increment unread for this conversation
      final hasConversation = state.conversations.any((c) => c.gameId == gameId);
      if (hasConversation) {
        final conv = state.conversations.firstWhere((c) => c.gameId == gameId);
        AppLogger.d('MessagesNotifier',
            'Optimistic +1 for ${gameId.substring(0, 8)}, was ${conv.unreadCount}');
        state = state.copyWith(
          conversations: state.conversations
              .map((c) => c.gameId == gameId
                  ? c.withUnreadCount(c.unreadCount + 1)
                  : c)
              .toList(),
        );
      } else {
        AppLogger.d('MessagesNotifier',
            'No conversation found for ${gameId.substring(0, 8)}');
      }
    }

    // Always fetch from backend — even if activeGameId matches (safety net
    // in case activeGameId is stale from a failed closeChat)
    fetchConversations();
  }

  Future<void> hideConversation(String gameId) async {
    try {
      await ref.read(messagesRepositoryProvider).hideConversation(gameId);
      state = state.copyWith(
        conversations:
            state.conversations.where((c) => c.gameId != gameId).toList(),
      );
    } catch (e, st) {
      AppLogger.e('MessagesNotifier', 'hideConversation failed', e, st);
    }
  }

  void clearUnread(String gameId) {
    state = state.copyWith(
      conversations: state.conversations
          .map((c) => c.gameId == gameId ? c.withZeroUnread() : c)
          .toList(),
    );
  }

  // ── Chat actif ────────────────────────────────────────────────

  Future<void> openChat(String gameId) async {
    _pollingTimer?.cancel();
    state = state.copyWith(
      activeGameId: gameId,
      activeMessages: const [],
      isLoadingMessages: true,
      clearErrorMessages: true,
    );

    try {
      final messages =
          await ref.read(messagesRepositoryProvider).getMessages(gameId);
      state = state.copyWith(
        activeMessages: messages,
        isLoadingMessages: false,
      );
      _markAsRead(gameId);
      _startPolling(gameId);
    } on AppException catch (e) {
      AppLogger.w('MessagesNotifier', 'openChat failed: $e');
      state = state.copyWith(
        errorMessages: e.message,
        isLoadingMessages: false,
      );
    } catch (e, st) {
      AppLogger.e('MessagesNotifier', 'openChat failed', e, st);
      state = state.copyWith(
        errorMessages: 'Erreur inconnue',
        isLoadingMessages: false,
      );
    }
  }

  void closeChat() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    state = state.copyWith(clearActiveChat: true);
  }

  Future<void> sendMessage(String content) async {
    final gameId = state.activeGameId;
    if (gameId == null) return;

    state = state.copyWith(isSending: true);
    try {
      final newMessage =
          await ref.read(messagesRepositoryProvider).sendMessage(gameId, content);
      state = state.copyWith(
        activeMessages: [...state.activeMessages, newMessage],
        isSending: false,
      );
      // Rafraîchit les conversations pour mettre à jour l'aperçu
      fetchConversations();
    } on AppException catch (e) {
      AppLogger.w('MessagesNotifier', 'sendMessage failed: $e');
      state = state.copyWith(isSending: false);
      rethrow;
    } catch (e, st) {
      AppLogger.e('MessagesNotifier', 'sendMessage failed', e, st);
      state = state.copyWith(isSending: false);
      rethrow;
    }
  }

  // ── Privé ─────────────────────────────────────────────────────

  void _startPolling(String gameId) {
    _pollingTimer = Timer.periodic(
      const Duration(seconds: AppConstants.messagePollingSeconds),
      (_) => _pollMessages(gameId),
    );
  }

  Future<void> _pollMessages(String gameId) async {
    // Si le chat actif a changé entre-temps, on ignore
    if (state.activeGameId != gameId) return;

    try {
      final fresh =
          await ref.read(messagesRepositoryProvider).getMessages(gameId);
      final current = state.activeMessages;

      if (fresh.length != current.length ||
          (fresh.isNotEmpty &&
              current.isNotEmpty &&
              fresh.last.id != current.last.id)) {
        state = state.copyWith(activeMessages: fresh);
        _markAsRead(gameId);
      }
    } catch (e) {
      AppLogger.w('MessagesNotifier', 'polling error: $e');
    }
  }

  void _markAsRead(String gameId) {
    ref.read(messagesRepositoryProvider).markRead(gameId).catchError((e) {
      AppLogger.w('MessagesNotifier', 'markRead failed: $e');
    });
    clearUnread(gameId);
  }
}
