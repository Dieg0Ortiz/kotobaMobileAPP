import 'package:equatable/equatable.dart';

/// Clases selladas de error para manejo funcional con dartz Either.
///
/// Se usan en las interfaces de repositorio: `Future<Either<Failure, T>>`.
/// La capa de presentación nunca maneja Failures directamente —
/// los ViewModels las convierten en mensajes de UI.
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Sin conexión a internet.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

/// Error del servidor (4xx, 5xx).
final class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Token expirado y no renovable.
final class AuthFailure extends Failure {
  const AuthFailure(
      [super.message = 'Sesión expirada. Por favor inicia sesión de nuevo.']);
}

/// Error de caché/storage local.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al acceder al almacenamiento local']);
}

/// Recurso no encontrado.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}
