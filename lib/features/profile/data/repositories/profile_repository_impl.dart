import 'package:dartz/dartz.dart';

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
}
