import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/comment.dart';

/// Contrato del repositorio de contenido (obras, capítulos, comentarios para lectura).
abstract class IContentRepository {
  Future<Either<Failure, Work>> getWorkDetail(String workId);
  Future<Either<Failure, List<Chapter>>> getChapters(String workId);
  Future<Either<Failure, Chapter>> getChapter(String chapterId);
  Future<Either<Failure, Chapter>> createChapter(Map<String, dynamic> data);
  Future<Either<Failure, Chapter>> updateChapter(String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteChapter(String chapterId);

  // Comments
  Future<Either<Failure, List<Comment>>> getComments(String workId);
  Future<Either<Failure, Comment>> createComment(String workId, String content);
}
