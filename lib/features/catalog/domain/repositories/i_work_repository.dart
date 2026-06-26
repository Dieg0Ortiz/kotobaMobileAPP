import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/work.dart';

abstract class IWorkRepository {
  Future<Either<Failure, List<Work>>> getTrending();
  Future<Either<Failure, List<Work>>> getRecommended();
  Future<Either<Failure, List<Work>>> search(String query, {String? genre});
  Future<Either<Failure, Work>> getWorkById(String id);
  Future<Either<Failure, Work>> createWork(Map<String, dynamic> workData);
  Future<Either<Failure, Work>> updateWork(String id, Map<String, dynamic> workData);
  Future<Either<Failure, List<Work>>> getWorksByAuthor(String authorId);
}
