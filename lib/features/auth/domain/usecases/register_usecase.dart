import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_token.dart';
import '../repositories/i_auth_repository.dart';

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String username;
  final int? age;
  final String? country;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.username,
    this.age,
    this.country,
  });

  @override
  List<Object?> get props => [email, password, username, age, country];
}

class RegisterUseCase {
  final IAuthRepository _repository;

  const RegisterUseCase({required IAuthRepository repository})
      : _repository = repository;

  Future<Either<Failure, AuthToken>> execute(RegisterParams params) {
    return _repository.register(
      params.email,
      params.password,
      params.username,
      age: params.age,
      country: params.country,
    );
  }
}
