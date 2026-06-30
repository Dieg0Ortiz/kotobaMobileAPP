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
  Future<Either<Failure, Map<String, dynamic>>> getAuthorProfile(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = MockData.currentUser;
    return Right({
      'id': user.id,
      'name': user.name,
      'username': user.username,
      'avatarUrl': user.avatarUrl,
      'bio': user.bio,
      'works': [],
    });
  }

  @override
  Future<Either<Failure, User>> updateProfile(
      Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(
      List<int> bytes, String filename) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const Right('https://mock.example.com/avatars/mock_avatar.png');
  }

  @override
  Future<Either<Failure, void>> followUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unfollowUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getFollowingAuthors() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right([]);
  }
}
