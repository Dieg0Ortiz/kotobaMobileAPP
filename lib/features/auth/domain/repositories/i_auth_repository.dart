import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_token.dart';
import '../entities/user.dart';

/// Contrato del repositorio de autenticación.
///
/// Principio DIP: el dominio define esta abstracción.
/// La capa de datos provee la implementación (mock ahora, real después).
///
/// Principio ISP: solo métodos de autenticación.
abstract class IAuthRepository {
  Future<Either<Failure, AuthToken>> login(String email, String password);
  Future<Either<Failure, AuthToken>> register(
      String email, String password, String username);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  // 🔄 BACKEND INTEGRATION: descomentar cuando se implemente refresh
  // Future<Either<Failure, AuthToken>> refreshToken();
}
