import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages_provider.g.dart';

/// Provider pour la liste des conversations
/// TODO: Implémenter la logique de gestion des conversations
@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  @override
  AsyncValue<void> build() {
    // TODO: Charger les conversations
    return const AsyncValue.data(null);
  }

  // TODO: Implémenter loadConversations()
  // TODO: Implémenter refresh()
  // TODO: Implémenter startConversation(userId)
}

/// Provider pour les messages d'une conversation
@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  @override
  AsyncValue<void> build(String conversationId) {
    // TODO: Charger les messages de la conversation
    return const AsyncValue.data(null);
  }

  // TODO: Implémenter loadMessages()
  // TODO: Implémenter sendMessage(content)
  // TODO: Implémenter loadMore() pour pagination
  // TODO: Implémenter markAsRead()
}

/// Provider pour le compteur de messages non lus
@riverpod
int unreadMessagesCount(UnreadMessagesCountRef ref) {
  // TODO: Calculer le nombre de messages non lus
  return 0;
}
