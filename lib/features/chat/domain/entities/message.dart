import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final String senderUsername;
  final String? senderAvatarUrl;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.metadata,
    required this.createdAt,
    required this.senderUsername,
    this.senderAvatarUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderUsername: json['sender_username'] as String? ?? 'Unknown',
      senderAvatarUrl: json['sender_avatar_url'] as String?,
    );
  }

  bool get isWorkShare => messageType == 'work_share';

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        content,
        messageType,
        metadata,
        createdAt,
        senderUsername,
        senderAvatarUrl,
      ];
}
