import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/work.dart';
import '../../domain/repositories/i_work_repository.dart';

/// Mock repository de obras — retorna datos estáticos con delay simulado.
///
/// 🔄 BACKEND INTEGRATION: reemplazar por WorkRepositoryImpl(remoteDataSource: Dio)
class MockWorkRepository implements IWorkRepository {
  @override
  Future<Either<Failure, List<Work>>> getTrending() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Right(MockData.trendingWorks);
  }

  @override
  Future<Either<Failure, List<Work>>> getRecommended() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(MockData.trendingWorks.take(3).toList());
  }

  @override
  Future<Either<Failure, List<Work>>> search(String query,
      {String? genre}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    var results = MockData.searchResults;

    if (query.isNotEmpty) {
      results = results
          .where((w) =>
              w.title.toLowerCase().contains(query.toLowerCase()) ||
              w.authorName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    if (genre != null && genre != 'Todos') {
      results = results.where((w) => w.genre == genre).toList();
    }
    return Right(results);
  }

  @override
  Future<Either<Failure, Work>> getWorkById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final work = MockData.searchResults.firstWhere((w) => w.id == id);
      return Right(work);
    } catch (_) {
      return const Left(NotFoundFailure('Obra no encontrada'));
    }
  }

  @override
  Future<Either<Failure, Work>> createWork(Map<String, dynamic> workData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(MockData.trendingWorks.first);
  }

  @override
  Future<Either<Failure, Work>> updateWork(String id, Map<String, dynamic> workData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(MockData.trendingWorks.first);
  }

  @override
  Future<Either<Failure, List<Work>>> getWorksByAuthor(String authorId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Right(MockData.myAuthoredWorks);
  }
}
