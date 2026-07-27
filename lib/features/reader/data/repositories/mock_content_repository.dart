import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/i_content_repository.dart';

/// Mock repository de contenido — retorna datos estáticos con delay simulado.
class MockContentRepository implements IContentRepository {
  @override
  Future<Either<Failure, Work>> getWorkDetail(String workId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final work = MockData.searchResults.firstWhere((w) => w.id == workId);
      return Right(work);
    } catch (_) {
      return const Left(NotFoundFailure('Obra no encontrada'));
    }
  }

  @override
  Future<Either<Failure, List<Chapter>>> getChapters(String workId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Right(MockData.sampleChapters);
  }

  @override
  Future<Either<Failure, Chapter>> getChapter(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final chapter =
          MockData.sampleChapters.firstWhere((c) => c.id == chapterId);
      return Right(chapter);
    } catch (_) {
      return const Left(NotFoundFailure('Capítulo no encontrado'));
    }
  }

  @override
  Future<Either<Failure, Chapter>> createChapter(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(MockData.sampleChapters.first);
  }

  @override
  Future<Either<Failure, Chapter>> updateChapter(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(MockData.sampleChapters.first);
  }

  @override
  Future<Either<Failure, void>> deleteChapter(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(String workId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right([]);
  }

  @override
  Future<Either<Failure, Comment>> createComment(String workId, String content) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(Comment(
      id: 'mock_cmt',
      workId: workId,
      userId: 'mock_user',
      content: content,
      createdAt: DateTime.now(),
      username: 'MockUser',
    ));
  }

  @override
  Future<Either<Failure, List<Comment>>> getChapterComments(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right([]);
  }

  @override
  Future<Either<Failure, Comment>> createChapterComment(String chapterId, String workId, String content) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(Comment(
      id: 'mock_chapter_cmt',
      workId: workId,
      chapterId: chapterId,
      userId: 'mock_user',
      content: content,
      createdAt: DateTime.now(),
      username: 'MockUser',
    ));
  }

  @override
  Future<Either<Failure, String>> getRecap(String chapterId, double progress) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right('Resumen mock: No hay contenido real disponible.');
  }

  @override
  Future<Either<Failure, Comment>> replyToComment(String commentId, String content, {String? workId, String? chapterId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(Comment(
      id: 'mock_reply',
      workId: workId ?? '',
      chapterId: chapterId,
      userId: 'mock_user',
      content: content,
      createdAt: DateTime.now(),
      username: 'MockUser',
      parentId: commentId,
    ));
  }

  @override
  Future<Either<Failure, void>> incrementView(String workId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMyVote(String workId) async {
    return const Right({'user_vote': 0});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> voteWork(String workId, int vote) async {
    return const Right({'rating': 4.5, 'rating_count': 10});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> unvoteWork(String workId) async {
    return const Right({'rating': 0, 'rating_count': 0});
  }

  @override
  Future<Either<Failure, bool>> isBookmarked(String workId) async {
    return const Right(false);
  }

  @override
  Future<Either<Failure, void>> bookmarkWork(String workId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unbookmarkWork(String workId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Work>>> getMyBookmarks() async {
    return const Right([]);
  }
}
