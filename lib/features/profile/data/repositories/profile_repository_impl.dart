import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../profile/domain/entities/dashboard_stats.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ApiClient _api;

  ProfileRepositoryImpl(this._api);

  @override
  Future<Either<Failure, User>> getProfile(String userId) async {
    final result = await _api.get<Map<String, dynamic>>(
      ApiConstants.userById(userId),
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(User.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, DashboardStats>> getAuthorStats(String authorId) async {
    final result = await _api.get<Map<String, dynamic>>(
      ApiConstants.userStats(authorId),
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(DashboardStats.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAuthorProfile(String userId) async {
    final result = await _api.get<Map<String, dynamic>>(
      '${ApiConstants.users}/$userId/profile',
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data),
    );
  }

  @override
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> data) async {
    final result = await _api.put<Map<String, dynamic>>(
      '${ApiConstants.users}/me',
      data: data,
    );
    return result.fold(
      (failure) => Left(failure),
      (json) => Right(User.fromJson(json)),
    );
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final result = await _api.upload<Map<String, dynamic>>(
        '${ApiConstants.users}/me/avatar',
        formData,
      );
      return result.fold(
        (failure) => Left(failure),
        (data) => Right(data['url'] as String),
      );
    } catch (e) {
      return Left(ServerFailure('Error al subir avatar'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadBanner(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final result = await _api.upload<Map<String, dynamic>>(
        '${ApiConstants.users}/me/banner',
        formData,
      );
      return result.fold(
        (failure) => Left(failure),
        (data) => Right(data['url'] as String),
      );
    } catch (e) {
      return Left(ServerFailure('Error al subir banner'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getFollowingAuthors() async {
    final result = await _api.get<List<dynamic>>(ApiConstants.followingAuthors);
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.cast<Map<String, dynamic>>()),
    );
  }

  @override
  Future<Either<Failure, void>> followUser(String userId) async {
    final result = await _api.post<dynamic>(
      '${ApiConstants.users}/$userId/follow',
    );
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> unfollowUser(String userId) async {
    final result = await _api.delete<dynamic>(
      '${ApiConstants.users}/$userId/follow',
    );
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, List<User>>> getNewAuthors() async {
    final result = await _api.get<List<dynamic>>(ApiConstants.newAuthors);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          final users = data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
          return Right(users);
        } catch (e) {
          return const Left(ServerFailure('Error parsing authors data'));
        }
      },
    );
  }
}
