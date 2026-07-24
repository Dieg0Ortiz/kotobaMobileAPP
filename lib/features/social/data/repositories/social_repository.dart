import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';

class SocialRepository {
  final ApiClient _api;

  SocialRepository(this._api);

  Future<Either<Failure, Map<String, dynamic>>> likeComment(String commentId) async {
    return _api.post<Map<String, dynamic>>('/comments/$commentId/like');
  }

  Future<Either<Failure, Map<String, dynamic>>> unlikeComment(String commentId) async {
    return _api.delete<Map<String, dynamic>>('/comments/$commentId/like');
  }

  Future<Either<Failure, Map<String, dynamic>>> getCommentLikes(String commentId) async {
    return _api.get<Map<String, dynamic>>('/comments/$commentId/likes');
  }

  Future<Either<Failure, List<dynamic>>> getCommentsWithLikes(String workId) async {
    return _api.get<List<dynamic>>(
      '/works/$workId/comments/with-likes',
      fromJson: (data) => data as List<dynamic>,
    );
  }
}
