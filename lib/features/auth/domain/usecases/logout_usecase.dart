import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/i_auth_repository.dart';

/// Caso de uso: Cerrar sesión.
class LogoutUseCase {
  final IAuthRepository _repository;

  const LogoutUseCase({required IAuthRepository repository})
      : _repository = repository;

  Future<Either<Failure, void>> execute() {
    return _repository.logout();
  }
}
