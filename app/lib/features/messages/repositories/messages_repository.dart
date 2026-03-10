import 'package:dio/dio.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/features/messages/entities/message.dart';
import 'package:tcg_matchmaker/features/messages/models/message_model.dart';

class MessagesRepository {
  final Dio _dio;

  MessagesRepository(this._dio);

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _dio.get('/messages/conversations');
      return (response.data as List)
          .map((json) =>
              ConversationModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message:
            e.response?.data?['error'] ?? 'Erreur chargement conversations',
      );
    }
  }

  Future<List<Message>> getMessages(String gameId) async {
    try {
      final response = await _dio.get('/games/$gameId/messages');
      return (response.data as List)
          .map((json) =>
              MessageModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? 'Erreur chargement messages',
      );
    }
  }

  Future<Message> sendMessage(String gameId, String content) async {
    try {
      final response = await _dio.post(
        '/games/$gameId/messages',
        data: {'content': content},
      );
      return MessageModel.fromJson(response.data as Map<String, dynamic>)
          .toEntity();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? 'Erreur envoi du message',
      );
    }
  }

  Future<void> markRead(String gameId) async {
    try {
      await _dio.put('/games/$gameId/messages/read');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? 'Erreur mise à jour lecture',
      );
    }
  }
}
