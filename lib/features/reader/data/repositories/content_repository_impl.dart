import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../reader/domain/entities/chapter.dart';
import '../../../reader/domain/entities/comment.dart';
import '../../../reader/domain/repositories/i_content_repository.dart';

class ContentRepositoryImpl implements IContentRepository {
  final ApiClient _api;

  ContentRepositoryImpl(this._api);

  Chapter _chapterFromJson(Map<String, dynamic> json) {
    return Chapter.fromJson(json);
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

  // ── Views ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> incrementView(String workId) async {
    final result = await _api.post<dynamic>(
      '${ApiConstants.works}/$workId/view',
    );
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  // ── Votes ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMyVote(String workId) async {
    final result = await _api.get<Map<String, dynamic>>(
      '${ApiConstants.works}/$workId/vote',
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> voteWork(String workId, int vote) async {
    final result = await _api.post<Map<String, dynamic>>(
      '${ApiConstants.works}/$workId/vote',
      data: {'vote': vote},
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> unvoteWork(String workId) async {
    final result = await _api.delete<Map<String, dynamic>>(
      '${ApiConstants.works}/$workId/vote',
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data),
    );
  }

  // ── Bookmarks ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> isBookmarked(String workId) async {
    final result = await _api.get<Map<String, dynamic>>(
      '${ApiConstants.bookmarks}/$workId',
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data['bookmarked'] as bool? ?? false),
    );
  }

  @override
  Future<Either<Failure, void>> bookmarkWork(String workId) async {
    final result = await _api.post<dynamic>(
      '${ApiConstants.bookmarks}/$workId',
    );
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> unbookmarkWork(String workId) async {
    final result = await _api.delete<dynamic>(
      '${ApiConstants.bookmarks}/$workId',
    );
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, List<Work>>> getMyBookmarks() async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.bookmarks}/mine',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (failure) => Left(failure),
      (list) {
        final works = list.map((e) {
          final bookmark = e as Map<String, dynamic>;
          final workJson = bookmark['work'] as Map<String, dynamic>? ?? {};
          return _workFromJson(workJson);
        }).toList();
        return Right(works);
      },
    );
  }

  // ── Comments ─────────────────────────────────────────────────────

  Comment _commentFromJson(Map<String, dynamic> json) {
    return Comment.fromJson(json);
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(String workId) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.works}/$workId/comments',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.map((e) => _commentFromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, Comment>> createComment(String workId, String content) async {
    final result = await _api.post<Map<String, dynamic>>(
      '${ApiConstants.works}/$workId/comments',
      data: {'content': content},
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(_commentFromJson(data)),
    );
  }
}
