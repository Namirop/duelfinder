import 'package:tcg_matchmaker/features/auth/entities/user_summary.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/messages/entities/message.dart';

class MessageModel {
  final String id;
  final String content;
  final Map<String, dynamic> sender;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.content,
    required this.sender,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        content: json['content'] as String,
        sender: json['sender'] as Map<String, dynamic>,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Message toEntity() => Message(
        id: id,
        content: content,
        sender: UserSummary(
          id: sender['id'] as String,
          username: sender['username'] as String,
          avatar: sender['avatar'] as String,
        ),
        createdAt: createdAt,
      );
}

class ConversationModel {
  final String gameId;
  final String gameType;
  final String address;
  final DateTime scheduledAt;
  final String status;
  final Map<String, dynamic> creator;
  final List<Map<String, dynamic>> participants;
  final Map<String, dynamic>? lastMessage;
  final int unreadCount;

  ConversationModel({
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

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        gameId: json['gameId'] as String,
        gameType: json['gameType'] as String,
        address: json['address'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        status: json['status'] as String,
        creator: json['creator'] as Map<String, dynamic>,
        participants:
            (json['participants'] as List).cast<Map<String, dynamic>>(),
        lastMessage: json['lastMessage'] as Map<String, dynamic>?,
        unreadCount: json['unreadCount'] as int,
      );

  Conversation toEntity() => Conversation(
        gameId: gameId,
        gameType: _parseGameType(gameType),
        address: address,
        scheduledAt: scheduledAt,
        status: _parseGameStatus(status),
        creator: UserSummary(
          id: creator['id'] as String,
          username: creator['username'] as String,
          avatar: creator['avatar'] as String,
        ),
        participants: participants
            .map((p) => UserSummary(
                  id: p['id'] as String,
                  username: p['username'] as String,
                  avatar: p['avatar'] as String,
                ))
            .toList(),
        lastMessage: lastMessage != null
            ? LastMessagePreview(
                id: lastMessage!['id'] as String,
                content: lastMessage!['content'] as String,
                senderId: lastMessage!['senderId'] as String,
                senderUsername: lastMessage!['senderUsername'] as String,
                createdAt: DateTime.parse(lastMessage!['createdAt'] as String),
              )
            : null,
        unreadCount: unreadCount,
      );

  static GameType _parseGameType(String value) {
    return GameType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GameType.POKEMON,
    );
  }

  static GameStatus _parseGameStatus(String value) {
    return GameStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GameStatus.OPEN,
    );
  }
}
