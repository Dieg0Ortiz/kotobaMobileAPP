import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../domain/repositories/i_analytics_repository.dart';

class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  final ApiClient _api;
  AnalyticsRepositoryImpl(this._api);

  @override
  Future<Either<Failure, String>> startSession({
    required String workId,
    required String chapterId,
    String? deviceType,
    String? platform,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      '${ApiConstants.analytics}/session/start',
      data: {
        'work_id': workId,
        'chapter_id': chapterId,
        'device_type': deviceType,
        'platform': platform,
      },
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data['session_id'] as String? ?? ''),
    );
  }

  @override
  Future<Either<Failure, void>> endSession(String sessionId, int durationSeconds) async {
    final result = await _api.post<dynamic>(
      '${ApiConstants.analytics}/session/end',
      data: {
        'session_id': sessionId,
        'duration_seconds': durationSeconds,
      },
    );
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> chapterRead({
    required String workId,
    required String chapterId,
    required double readProgress,
    required int timeSpentSeconds,
  }) async {
    final result = await _api.post<dynamic>(
      '${ApiConstants.analytics}/chapter-read',
      data: {
        'work_id': workId,
        'chapter_id': chapterId,
        'read_progress': readProgress,
        'time_spent_seconds': timeSpentSeconds,
      },
    );
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, AuthorOverview>> getOverview(String authorId) async {
    final result = await _api.get<Map<String, dynamic>>(
      '${ApiConstants.analytics}/author/$authorId/overview',
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(AuthorOverview.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, List<ChapterAnalytics>>> getChapterAnalytics(String authorId) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/author/$authorId/chapters',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.map((e) => ChapterAnalytics.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, SessionAnalytics>> getSessionAnalytics(String authorId) async {
    final result = await _api.get<Map<String, dynamic>>(
      '${ApiConstants.analytics}/author/$authorId/sessions',
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(SessionAnalytics.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, EngagementAnalytics>> getEngagement(String authorId) async {
    final result = await _api.get<Map<String, dynamic>>(
      '${ApiConstants.analytics}/author/$authorId/engagement',
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(EngagementAnalytics.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, List<GenreAnalytics>>> getGenreAnalytics(String authorId) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/author/$authorId/genres',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.map((e) => GenreAnalytics.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }
}
