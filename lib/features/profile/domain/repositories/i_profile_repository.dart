import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Contrato del repositorio de perfil y dashboard de autor.
abstract class IProfileRepository {
  Future<Either<Failure, User>> getProfile(String userId);
  Future<Either<Failure, DashboardStats>> getAuthorStats(String authorId);
}
