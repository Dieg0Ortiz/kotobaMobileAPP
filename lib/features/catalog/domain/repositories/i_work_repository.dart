import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/work.dart';

/// Contrato del repositorio de obras/catálogo.
///
/// 🔄 BACKEND INTEGRATION: el futuro WorkRepositoryImpl
/// recibirá un RemoteDataSource con Dio.
abstract class IWorkRepository {
  Future<Either<Failure, List<Work>>> getTrending();
  Future<Either<Failure, List<Work>>> getRecommended();
  Future<Either<Failure, List<Work>>> search(String query, {String? genre});
  Future<Either<Failure, Work>> getWorkById(String id);
}
