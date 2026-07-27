import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String workId;
  final String? chapterId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? username;
  final String? avatarUrl;
  final int likeCount;
  final bool isLiked;
  final String? parentId;
  final int replyCount;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.workId,
    this.chapterId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.username,
    this.avatarUrl,
    this.likeCount = 0,
    this.isLiked = false,
    this.parentId,
    this.replyCount = 0,
    this.replies = const [],
  });

  Comment copyWith({int? likeCount, bool? isLiked, int? replyCount, List<Comment>? replies}) {
    return Comment(
      id: id,
      workId: workId,
      chapterId: chapterId,
      userId: userId,
      content: content,
      createdAt: createdAt,
      username: username,
      avatarUrl: avatarUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      parentId: parentId,
      replyCount: replyCount ?? this.replyCount,
      replies: replies ?? this.replies,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    final rawReplies = json['replies'] as List<dynamic>?;
    return Comment(
      id: json['id'] as String,
      workId: json['work_id'] as String,
      chapterId: json['chapter_id'] as String?,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      username: user?['username'] as String?,
      avatarUrl: user?['avatar_url'] as String?,
      likeCount: (json['like_count'] as int?) ?? 0,
      isLiked: (json['is_liked'] as bool?) ?? false,
      parentId: json['parent_id'] as String?,
      replyCount: (json['reply_count'] as int?) ?? 0,
      replies: rawReplies != null
          ? rawReplies.map((r) => Comment.fromJson(r as Map<String, dynamic>)).toList()
          : [],
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return 'hace ${diff.inDays ~/ 7}sem';
  }

  @override
  List<Object?> get props => [id];
}
