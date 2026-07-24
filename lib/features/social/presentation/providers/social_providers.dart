import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../reader/domain/entities/comment.dart';
import '../../data/repositories/social_repository.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  final api = ref.read(socialApiClientProvider);
  return SocialRepository(api);
});

final commentLikesProvider =
    FutureProvider.family<({bool liked, int likeCount}), String>((ref, commentId) async {
  final repo = ref.read(socialRepositoryProvider);
  final result = await repo.getCommentLikes(commentId);
  return result.fold(
    (f) => (liked: false, likeCount: 0),
    (data) => (
      liked: data['liked'] as bool? ?? false,
      likeCount: data['like_count'] as int? ?? 0,
    ),
  );
});

final workCommentsWithLikesProvider =
    FutureProvider.family<List<Comment>, String>((ref, workId) async {
  final repo = ref.read(socialRepositoryProvider);
  final result = await repo.getCommentsWithLikes(workId);
  return result.fold(
    (f) => <Comment>[],
    (list) => list
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
});
