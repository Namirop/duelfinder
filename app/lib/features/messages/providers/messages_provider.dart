import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/core/constants/app_constants.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/messages/entities/message.dart';

// ─── Conversations ────────────────────────────────────────────────────────────

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    return _load();
  }

  Future<List<Conversation>> _load() {
    return ref.read(messagesRepositoryProvider).getConversations();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Décrémente le unreadCount d'une conversation quand on l'ouvre
  void clearUnread(String gameId) {
    state = state.whenData(
      (list) =>
          list.map((c) => c.gameId == gameId ? _withZeroUnread(c) : c).toList(),
    );
  }

  Conversation _withZeroUnread(Conversation c) => Conversation(
        gameId: c.gameId,
        gameType: c.gameType,
        address: c.address,
        scheduledAt: c.scheduledAt,
        status: c.status,
        creator: c.creator,
        participants: c.participants,
        lastMessage: c.lastMessage,
        unreadCount: 0,
      );
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(
  ConversationsNotifier.new,
);

/// Nombre total de messages non lus (pour le badge nav bar)
final totalUnreadProvider = Provider<int>((ref) {
  return ref.watch(conversationsProvider).whenData((convs) {
        return convs.fold(0, (sum, c) => sum + c.unreadCount);
      }).valueOrNull ??
      0;
});

// ─── Messages d'une partie ────────────────────────────────────────────────────

class MessagesNotifier extends FamilyAsyncNotifier<List<Message>, String> {
  Timer? _timer;

  @override
  Future<List<Message>> build(String arg) async {
    ref.onDispose(() => _timer?.cancel());
    final messages = await _load();
    _startPolling();
    // Marquer comme lu à l'ouverture
    _markRead();
    return messages;
  }

  Future<List<Message>> _load() {
    return ref.read(messagesRepositoryProvider).getMessages(arg);
  }

  void _markRead() {
    ref.read(messagesRepositoryProvider).markRead(arg).catchError((e) {
      AppLogger.w('MessagesNotifier', 'markRead failed: $e');
    });
    // Met à jour le badge de la conv dans la liste
    ref.read(conversationsProvider.notifier).clearUnread(arg);
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: AppConstants.messagePollingSeconds), (_) async {
      try {
        final fresh = await _load();
        final current = state.valueOrNull;
        if (current == null) return;
        // Mise à jour seulement si nouveaux messages
        if (fresh.length != current.length ||
            (fresh.isNotEmpty &&
                current.isNotEmpty &&
                fresh.last.id != current.last.id)) {
          state = AsyncData(fresh);
          _markRead();
        }
      } catch (e) {
        AppLogger.w('MessagesNotifier', 'polling error: $e');
      }
    });
  }

  Future<void> sendMessage(String content) async {
    final repo = ref.read(messagesRepositoryProvider);
    try {
      final newMessage = await repo.sendMessage(arg, content);
      state = state.whenData((messages) => [...messages, newMessage]);
      // Rafraîchit la liste des conversations pour mettre à jour l'aperçu
      ref.read(conversationsProvider.notifier).refresh();
    } on Exception catch (e) {
      AppLogger.e(
          'MessagesNotifier', 'sendMessage failed', e, StackTrace.current);
      rethrow;
    }
  }
}

final messagesProvider =
    AsyncNotifierProviderFamily<MessagesNotifier, List<Message>, String>(
  MessagesNotifier.new,
);
