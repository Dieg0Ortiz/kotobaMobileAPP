import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient _api;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._api, this._storage);

  @override
  Future<Either<Failure, AuthToken>> login(String email, String password) async {
    final result = await _api.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        final session = data['session'] as Map<String, dynamic>;

        final token = AuthToken(
          accessToken: session['access_token'] as String,
          refreshToken: session['refresh_token'] as String,
          expiresAt: DateTime.fromMillisecondsSinceEpoch(
            (session['expires_at'] as int) * 1000,
          ),
        );

        _storage.saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        );

        return Right(token);
      },
    );
  }

  @override
  Future<Either<Failure, AuthToken>> register(
      String email, String password, String username, {int? age, String? country}) async {
    final body = <String, dynamic>{'email': email, 'password': password, 'username': username};
    if (age != null) body['age'] = age;
    if (country != null) body['country'] = country;

    final result = await _api.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: body,
    );

    return result.fold(
      (failure) => Left(failure),
      (_) {
        // Registration successful — user must confirm email
        return Right(AuthToken(
          accessToken: '',
          refreshToken: '',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        ));
      },
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await _storage.clearTokens();
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final result = await _api.get<Map<String, dynamic>>(
      ApiConstants.users,
      fromJson: (data) {
        if (data is List) {
          return data.first as Map<String, dynamic>;
        }
        return data as Map<String, dynamic>;
      },
    );

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(User.fromJson(data)),
    );
  }
}
