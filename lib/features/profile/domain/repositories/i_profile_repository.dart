import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Contrato del repositorio de perfil y dashboard de autor.
abstract class IProfileRepository {
  Future<Either<Failure, User>> getProfile(String userId);
  Future<Either<Failure, DashboardStats>> getAuthorStats(String authorId);

  // Public profile with works
  Future<Either<Failure, Map<String, dynamic>>> getAuthorProfile(String userId);

  // Profile edit
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, String>> uploadAvatar(List<int> bytes, String filename);
  Future<Either<Failure, String>> uploadBanner(List<int> bytes, String filename);

  // Follow system
  Future<Either<Failure, void>> followUser(String userId);
  Future<Either<Failure, void>> unfollowUser(String userId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getFollowingAuthors();
  
  // Discovery
  Future<Either<Failure, List<User>>> getNewAuthors();
}
