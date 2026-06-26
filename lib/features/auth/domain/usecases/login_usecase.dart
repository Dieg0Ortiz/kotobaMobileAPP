import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_token.dart';
import '../repositories/i_auth_repository.dart';

/// Parámetros del login.
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Caso de uso: Iniciar sesión.
///
/// Principio SRP: encapsula únicamente la lógica de login.
/// Principio DIP: depende de la abstracción [IAuthRepository].
class LoginUseCase {
  final IAuthRepository _repository;

  const LoginUseCase({required IAuthRepository repository})
      : _repository = repository;

  Future<Either<Failure, AuthToken>> execute(LoginParams params) {
    return _repository.login(params.email, params.password);
  }
}
