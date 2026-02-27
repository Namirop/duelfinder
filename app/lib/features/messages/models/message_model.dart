/// DTO pour un message
/// TODO: Implémenter les champs du message
class MessageModel {
  // TODO: Définir les champs
  // - id, conversationId, senderId, content, sentAt, readAt

  MessageModel();

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // TODO: Implémenter le parsing JSON
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    // TODO: Implémenter la sérialisation JSON
    throw UnimplementedError();
  }
}

/// DTO pour une conversation
class ConversationModel {
  // TODO: Définir les champs
  // - id, participants, lastMessage, unreadCount

  ConversationModel();

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    // TODO: Implémenter le parsing JSON
    throw UnimplementedError();
  }
}
