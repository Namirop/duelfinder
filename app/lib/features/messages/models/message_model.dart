import 'package:tcg_matchmaker/features/auth/models/user_summary_model.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/features/messages/entities/message.dart';

class MessageModel {
  final String id;
  final String content;
  final UserSummaryModel sender;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.content,
    required this.sender,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        content: json['content'] as String,
        sender:
            UserSummaryModel.fromJson(json['sender'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Message toEntity() => Message(
        id: id,
        content: content,
        sender: sender.toEntity(),
        createdAt: createdAt,
      );
}

class ConversationModel {
  final String gameId;
  final String gameType;
  final String address;
  final DateTime scheduledAt;
  final String status;
  final UserSummaryModel creator;
  final List<UserSummaryModel> participants;
  final Map<String, dynamic>? lastMessage;
  final int unreadCount;

  const ConversationModel({
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
        creator: UserSummaryModel.fromJson(
            json['creator'] as Map<String, dynamic>),
        participants: (json['participants'] as List)
            .map((p) =>
                UserSummaryModel.fromJson(p as Map<String, dynamic>))
            .toList(),
        lastMessage: json['lastMessage'] as Map<String, dynamic>?,
        unreadCount: json['unreadCount'] as int,
      );

  Conversation toEntity() => Conversation(
        gameId: gameId,
        gameType: _parseGameType(gameType),
        address: address,
        scheduledAt: scheduledAt,
        status: _parseGameStatus(status),
        creator: creator.toEntity(),
        participants: participants.map((p) => p.toEntity()).toList(),
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
