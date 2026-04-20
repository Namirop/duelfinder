import 'package:tcg_matchmaker/features/messages/entities/message.dart';

class MessagesState {
  // ── Conversations ─────────────────────────────────────────────
  final List<Conversation> conversations;
  final bool isLoadingConversations;
  final String? errorConversations;

  // ── Chat actif ────────────────────────────────────────────────
  final String? activeGameId;
  final List<Message> activeMessages;
  final bool isLoadingMessages;
  final String? errorMessages;
  final bool isSending;

  const MessagesState({
    this.conversations = const [],
    this.isLoadingConversations = false,
    this.errorConversations,
    this.activeGameId,
    this.activeMessages = const [],
    this.isLoadingMessages = false,
    this.errorMessages,
    this.isSending = false,
  });

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  Conversation? conversationFor(String gameId) =>
      conversations.where((c) => c.gameId == gameId).firstOrNull;

  MessagesState copyWith({
    List<Conversation>? conversations,
    bool? isLoadingConversations,
    String? errorConversations,
    bool clearErrorConversations = false,
    String? activeGameId,
    bool clearActiveChat = false,
    List<Message>? activeMessages,
    bool? isLoadingMessages,
    String? errorMessages,
    bool clearErrorMessages = false,
    bool? isSending,
  }) {
    return MessagesState(
      conversations: conversations ?? this.conversations,
      isLoadingConversations:
          isLoadingConversations ?? this.isLoadingConversations,
      errorConversations: clearErrorConversations
          ? null
          : (errorConversations ?? this.errorConversations),
      activeGameId:
          clearActiveChat ? null : (activeGameId ?? this.activeGameId),
      activeMessages:
          clearActiveChat ? const [] : (activeMessages ?? this.activeMessages),
      isLoadingMessages:
          clearActiveChat ? false : (isLoadingMessages ?? this.isLoadingMessages),
      errorMessages: clearErrorMessages || clearActiveChat
          ? null
          : (errorMessages ?? this.errorMessages),
      isSending: clearActiveChat ? false : (isSending ?? this.isSending),
    );
  }
}
