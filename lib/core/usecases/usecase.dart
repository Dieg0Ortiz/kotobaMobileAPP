import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

/// Contrato base para todos los Use Cases de la aplicación.
///
/// Principio ISP: cada use case tiene una única interfaz con un solo método.
/// Principio SRP: cada use case encapsula una sola regla de negocio.
///
/// [T] es el tipo de retorno exitoso.
/// [Params] son los parámetros de entrada.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> execute(Params params);
}

/// Para use cases que no requieren parámetros.
class NoParams {
  const NoParams();
}
