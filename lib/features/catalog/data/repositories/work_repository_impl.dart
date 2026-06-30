import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../catalog/domain/repositories/i_work_repository.dart';

class WorkRepositoryImpl implements IWorkRepository {
  final ApiClient _api;

  WorkRepositoryImpl(this._api);

  Work _workFromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'] as String,
      title: json['title'] as String,
      authorId: json['author_id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
      synopsis: json['synopsis'] as String? ?? '',
      genre: json['genre'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] as String? ?? 'ongoing',
      chapterCount: json['chapter_count'] as int? ?? 0,
      wordCount: json['word_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      language: json['language'] as String? ?? 'es',
      frequency: json['frequency'] as String?,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, List<Work>>> getTrending() async {
    final result = await _api.get<List<dynamic>>(
      ApiConstants.works,
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.map((e) => _workFromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, List<Work>>> getRecommended() async {
    return getTrending();
  }

  @override
  Future<Either<Failure, List<Work>>> search(String query, {String? genre}) async {
    // Semantic search via BETO cuando hay query textual
    if (query.isNotEmpty) {
      final params = <String, dynamic>{'q': query};
      if (genre != null && genre != 'Todos') params['genre'] = genre;

      final result = await _api.get<Map<String, dynamic>>(
        ApiConstants.search,
        queryParameters: params,
      );
      return result.fold(
        (failure) => Left(failure),
        (data) {
          final results = (data['results'] as List<dynamic>?) ?? [];
          return Right(results.map((e) => _workFromJson(e as Map<String, dynamic>)).toList());
        },
      );
    }

    // Sin query: filtrar por género con endpoint tradicional
    final params = <String, dynamic>{};
    if (genre != null && genre != 'Todos') params['genre'] = genre;

    final result = await _api.get<List<dynamic>>(
      ApiConstants.works,
      queryParameters: params.isNotEmpty ? params : null,
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.map((e) => _workFromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, Work>> getWorkById(String id) async {
    final result = await _api.get<Map<String, dynamic>>(
      ApiConstants.workById(id),
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(_workFromJson(data)),
    );
  }

  @override
  Future<Either<Failure, Work>> createWork(Map<String, dynamic> workData) async {
    final result = await _api.post<Map<String, dynamic>>(
      ApiConstants.works,
      data: workData,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(_workFromJson(data)),
    );
  }

  @override
  Future<Either<Failure, Work>> updateWork(String id, Map<String, dynamic> workData) async {
    final result = await _api.put<Map<String, dynamic>>(
      ApiConstants.workById(id),
      data: workData,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(_workFromJson(data)),
    );
  }

  @override
  Future<Either<Failure, List<Work>>> getWorksByAuthor(String authorId) async {
    final result = await _api.get<List<dynamic>>(
      ApiConstants.works,
      queryParameters: {'author_id': authorId},
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.map((e) => _workFromJson(e as Map<String, dynamic>)).toList()),
    );
  }
}
