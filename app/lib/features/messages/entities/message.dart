import 'package:tcg_matchmaker/features/auth/entities/user_summary.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';

class Message {
  final String id;
  final String content;
  final UserSummary sender;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.createdAt,
  });
}

class Conversation {
  final String gameId;
  final GameType gameType;
  final String address;
  final DateTime scheduledAt;
  final GameStatus status;
  final UserSummary creator;
  final List<UserSummary> participants;
  final LastMessagePreview? lastMessage;
  final int unreadCount;

  const Conversation({
    required this.gameId,
    required this.gameType,
    required this.address,
    required this.scheduledAt,
    required this.status,
    required this.creator,
    required this.participants,
    required this.lastMessage,
    required this.unreadCount,
  });

  bool get isArchived =>
      status == GameStatus.FINISHED || status == GameStatus.CANCELLED;

  Conversation withUnreadCount(int count) => Conversation(
        gameId: gameId,
        gameType: gameType,
        address: address,
        scheduledAt: scheduledAt,
        status: status,
        creator: creator,
        participants: participants,
        lastMessage: lastMessage,
        unreadCount: count,
      );

  Conversation withZeroUnread() => withUnreadCount(0);
}

class LastMessagePreview {
  final String id;
  final String content;
  final String senderId;
  final String senderUsername;
  final DateTime createdAt;

  const LastMessagePreview({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderUsername,
    required this.createdAt,
  });
}
