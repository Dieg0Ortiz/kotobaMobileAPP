import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../domain/entities/chapter.dart';

/// Contrato del repositorio de contenido (obras y capítulos para lectura).
abstract class IContentRepository {
  Future<Either<Failure, Work>> getWorkDetail(String workId);
  Future<Either<Failure, List<Chapter>>> getChapters(String workId);
  Future<Either<Failure, Chapter>> getChapter(String chapterId);
}
