import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Repositorio de autenticación con datos mock.
///
/// Simula latencia de red con Future.delayed.
/// Acepta cualquier email con formato válido y password >= 6 chars.
///
/// 🔄 BACKEND INTEGRATION: reemplazar esta clase por AuthRepositoryImpl
/// que use Dio + SecureStorage para JWT real.
class MockAuthRepository implements IAuthRepository {
  @override
  Future<Either<Failure, AuthToken>> login(
      String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!email.contains('@') || password.length < 6) {
      return const Left(AuthFailure('Credenciales inválidas'));
    }
    return Right(MockData.authToken);
  }

  @override
  Future<Either<Failure, AuthToken>> register(
      String email, String password, String username, {int? age, String? country}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!email.contains('@') || password.length < 6 || username.isEmpty) {
      return const Left(
          AuthFailure('Por favor completa todos los campos correctamente'));
    }
    return Right(MockData.authToken);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Right(MockData.currentUser);
  }
}
