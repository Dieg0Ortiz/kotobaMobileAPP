import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/i_chat_repository.dart';

class ChatRepositoryImpl implements IChatRepository {
  final ApiClient _api;

  ChatRepositoryImpl(this._api);

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    final result = await _api.get<List<dynamic>>('/conversations');
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.map((json) => Conversation.fromJson(json as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, Conversation>> createOrGetConversation(String otherUserId) async {
    final result = await _api.post<Map<String, dynamic>>(
      '/conversations',
      data: {'other_user_id': otherUserId},
    );
    return result.fold(
      (failure) => Left(failure),
      (data) async {
        final convResult = await _api.get<List<dynamic>>('/conversations');
        return convResult.fold(
          (failure) => Left(failure),
          (convs) {
            final conv = convs.firstWhere(
              (c) => (c as Map<String, dynamic>)['id'] == data['id'],
              orElse: () => data,
            );
            return Right(Conversation.fromJson(conv as Map<String, dynamic>));
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    final result = await _api.get<List<dynamic>>(
      '/conversations/$conversationId/messages',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.map((json) => ChatMessage.fromJson(json as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(String conversationId, String content, {String messageType = 'text', Map<String, dynamic>? metadata}) async {
    final result = await _api.post<Map<String, dynamic>>(
      '/conversations/$conversationId/messages',
      data: {
        'content': content,
        'message_type': messageType,
        if (metadata != null) 'metadata': metadata,
      },
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(ChatMessage.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    final result = await _api.put<Map<String, dynamic>>('/conversations/$conversationId/read');
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String conversationId) async {
    final result = await _api.get<Map<String, dynamic>>('/conversations/$conversationId/unread-count');
    return result.fold(
      (failure) => Left(failure),
      (data) => Right((data['count'] as num?)?.toInt() ?? 0),
    );
  }
}
