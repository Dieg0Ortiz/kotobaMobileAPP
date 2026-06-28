import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../reader/domain/entities/chapter.dart';
import '../../../reader/domain/repositories/i_content_repository.dart';

class ContentRepositoryImpl implements IContentRepository {
  final ApiClient _api;

  ContentRepositoryImpl(this._api);

  Chapter _chapterFromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      workId: json['work_id'] as String? ?? '',
      number: json['order_number'] as int? ?? json['number'] as int? ?? 0,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      wordCount: json['word_count'] as int? ?? 0,
      readTimeMinutes: json['read_time_minutes'] as int? ?? 0,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ?? DateTime.now(),
      isLocked: json['is_locked'] as bool? ?? false,
    );
  }

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
  Future<Either<Failure, Work>> getWorkDetail(String workId) async {
    final result = await _api.get<Map<String, dynamic>>(
      ApiConstants.workById(workId),
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(_workFromJson(data)),
    );
  }

  @override
  Future<Either<Failure, List<Chapter>>> getChapters(String workId) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.works}/$workId/chapters',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.map((e) => _chapterFromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, Chapter>> getChapter(String chapterId) async {
    final result = await _api.get<Map<String, dynamic>>(
      ApiConstants.chapterById(chapterId),
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(_chapterFromJson(data)),
    );
  }

  @override
  Future<Either<Failure, Chapter>> createChapter(Map<String, dynamic> data) async {
    final result = await _api.post<Map<String, dynamic>>(
      ApiConstants.chapters,
      data: data,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(_chapterFromJson(data)),
    );
  }

  @override
  Future<Either<Failure, Chapter>> updateChapter(String id, Map<String, dynamic> data) async {
    final result = await _api.put<Map<String, dynamic>>(
      ApiConstants.chapterById(id),
      data: data,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(_chapterFromJson(data)),
    );
  }

  @override
  Future<Either<Failure, void>> deleteChapter(String id) async {
    final result = await _api.delete<dynamic>(
      ApiConstants.chapterById(id),
    );
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}
