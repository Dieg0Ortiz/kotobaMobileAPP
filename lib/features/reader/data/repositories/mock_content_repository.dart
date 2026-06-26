import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../domain/entities/chapter.dart';
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
    // En mock, devolvemos los mismos capítulos para cualquier obra
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
}
