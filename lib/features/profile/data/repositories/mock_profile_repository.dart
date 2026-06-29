import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// Mock repository para perfil y dashboard.
class MockProfileRepository implements IProfileRepository {
  @override
  Future<Either<Failure, User>> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // En mock devolvemos siempre el currentUser
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, DashboardStats>> getAuthorStats(
      String authorId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Right(MockData.dashboardStats);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAuthorProfile(String userId) async {
    return Left(ServerFailure('Mock no implementado'));
  }

  @override
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> data) async {
    return Left(ServerFailure('Mock no implementado'));
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(List<int> bytes, String filename) async {
    return Left(ServerFailure('Mock no implementado'));
  }

  @override
  Future<Either<Failure, void>> followUser(String userId) async {
    return Left(ServerFailure('Mock no implementado'));
  }

  @override
  Future<Either<Failure, void>> unfollowUser(String userId) async {
    return Left(ServerFailure('Mock no implementado'));
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getFollowingAuthors() async {
    return Left(ServerFailure('Mock no implementado'));
  }
}
