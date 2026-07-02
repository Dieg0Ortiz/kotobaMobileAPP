import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// Mock repository para perfil y dashboard.
class MockProfileRepository implements IProfileRepository {
  final Set<String> _followedUsers = {};

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
    final user = MockData.currentUser; // O MockData.newAuthors.firstWhere(...) para simular el usuario real
    
    // Si queremos simular al usuario javier que se ve en la screenshot:
    final mockJavier = {
      'id': userId,
      'username': 'javier',
      'avatarUrl': 'https://picsum.photos/seed/javier/200',
      'bannerUrl': 'https://picsum.photos/seed/javier_banner/800/300',
      'bio': 'dsds',
      'works_count': 4,
      'followers_count': 1 + (_followedUsers.contains(userId) ? 1 : 0),
      'following_count': 2,
      'is_followed_by_me': _followedUsers.contains(userId),
      'works': MockData.myDraftWorks.map((w) => {
        'id': w.id,
        'title': w.title,
        'author_id': w.authorId,
        'author_name': w.authorName,
        'cover_url': w.coverUrl,
        'synopsis': w.synopsis,
        'genre': w.genre,
        'tags': w.tags,
        'status': w.status,
        'chapter_count': w.chapterCount,
        'word_count': w.wordCount,
        'view_count': w.viewCount,
        'rating': w.rating,
        'rating_count': w.ratingCount,
        'published_at': w.publishedAt.toIso8601String(),
        'updated_at': w.updatedAt.toIso8601String(),
      }).toList(),
    };
    
    // Si userId = me o current, devolver el currentUser normal, pero para este mock, usamos a javier
    return Right(mockJavier);
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
  Future<Either<Failure, String>> uploadBanner(
      List<int> bytes, String filename) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const Right('https://mock.example.com/banners/mock_banner.png');
  }

  @override
  Future<Either<Failure, void>> followUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _followedUsers.add(userId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unfollowUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _followedUsers.remove(userId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<User>>> getNewAuthors() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(MockData.newAuthors);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getFollowingAuthors() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right([]);
  }
}
