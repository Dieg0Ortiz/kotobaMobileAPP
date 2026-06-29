import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import 'secure_storage_service.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  Failure _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkFailure('Tiempo de espera agotado');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Sin conexión al servidor');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['error'] as String? ?? 'Error del servidor';
        if (statusCode == 401) return AuthFailure(message);
        if (statusCode == 404) return NotFoundFailure(message);
        return ServerFailure(message, statusCode: statusCode);
      default:
        return const ServerFailure('Error inesperado');
    }
  }

  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      if (fromJson != null) {
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Future<Either<Failure, T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.post(path, data: data);
      if (fromJson != null) {
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Future<Either<Failure, T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.put(path, data: data);
      if (fromJson != null) {
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Future<Either<Failure, T>> delete<T>(
    String path, {
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.delete(path);
      if (fromJson != null) {
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Future<Either<Failure, T>> upload<T>(
    String path,
    FormData data, {
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.put(path, data: data, options: Options(
        contentType: 'multipart/form-data',
      ));
      if (fromJson != null) {
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }
}
