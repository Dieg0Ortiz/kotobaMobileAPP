import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class IChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();
  Future<Either<Failure, Conversation>> createOrGetConversation(String otherUserId);
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId, {int limit = 50, int offset = 0});
  Future<Either<Failure, ChatMessage>> sendMessage(String conversationId, String content, {String messageType = 'text', Map<String, dynamic>? metadata});
  Future<Either<Failure, void>> markAsRead(String conversationId);
  Future<Either<Failure, int>> getUnreadCount(String conversationId);
}
