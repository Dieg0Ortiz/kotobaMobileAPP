import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String otherUserId;
  final String otherUsername;
  final String? otherAvatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUsername,
    this.otherAvatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      otherUserId: json['other_user_id'] as String,
      otherUsername: json['other_username'] as String,
      otherAvatarUrl: json['other_avatar_url'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        otherUserId,
        otherUsername,
        otherAvatarUrl,
        lastMessage,
        lastMessageAt,
        unreadCount,
      ];
}
