import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../entities/analytics_entities.dart';
import '../repositories/i_analytics_repository.dart';

class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  final ApiClient _api;
  AnalyticsRepositoryImpl(this._api);

  @override
  Future<Either<Failure, String>> startSession({required String workId, required String chapterId, String? deviceType, String? platform}) async {
    final result = await _api.post<Map<String, dynamic>>(
      '${ApiConstants.analytics}/session/start',
      data: {'work_id': workId, 'chapter_id': chapterId, 'device_type': deviceType, 'platform': platform},
    );
    return result.fold((f) => Left(f), (data) => Right(data['session_id'] as String? ?? ''));
  }

  @override
  Future<Either<Failure, void>> endSession(String sessionId, int durationSeconds) async {
    final result = await _api.post<dynamic>(
      '${ApiConstants.analytics}/session/end',
      data: {'session_id': sessionId, 'duration_seconds': durationSeconds},
    );
    return result.fold((f) => Left(f), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> chapterRead({required String workId, required String chapterId, required double readProgress, required int timeSpentSeconds}) async {
    final result = await _api.post<dynamic>(
      '${ApiConstants.analytics}/chapter-read',
      data: {'work_id': workId, 'chapter_id': chapterId, 'read_progress': readProgress, 'time_spent_seconds': timeSpentSeconds},
    );
    return result.fold((f) => Left(f), (_) => const Right(null));
  }

  // ── Story Analytics ─────────────────────────────────────────

  @override
  Future<Either<Failure, StoryOverview>> getStoryOverview(String workId) async {
    final result = await _api.get<Map<String, dynamic>>('${ApiConstants.analytics}/story/$workId/overview');
    return result.fold((f) => Left(f), (data) => Right(StoryOverview.fromJson(data)));
  }

  @override
  Future<Either<Failure, List<VoteTrendPoint>>> getStoryVoteTrend(String workId, {int days = 30}) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/story/$workId/vote-trend',
      queryParameters: {'days': days},
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.map((e) => VoteTrendPoint.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, ReaderDemographics>> getStoryDemographics(String workId) async {
    final result = await _api.get<Map<String, dynamic>>('${ApiConstants.analytics}/story/$workId/demographics');
    return result.fold((f) => Left(f), (data) => Right(ReaderDemographics.fromJson(data)));
  }

  @override
  Future<Either<Failure, List<ChapterAnalytics>>> getStoryChapters(String workId) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/story/$workId/chapters',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.map((e) => ChapterAnalytics.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, ReadingPeaksData>> getStoryPeaks(String workId) async {
    final result = await _api.get<Map<String, dynamic>>('${ApiConstants.analytics}/story/$workId/peaks');
    return result.fold((f) => Left(f), (data) => Right(ReadingPeaksData.fromJson(data)));
  }

  @override
  Future<Either<Failure, List<ReReadPattern>>> getStoryReReads(String workId) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/story/$workId/re-reads',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.map((e) => ReReadPattern.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  // ── Author Dashboard ────────────────────────────────────────

  @override
  Future<Either<Failure, AuthorDashboardOverview>> getAuthorDashboardOverview(String authorId) async {
    final result = await _api.get<Map<String, dynamic>>('${ApiConstants.analytics}/dashboard/$authorId/overview');
    return result.fold((f) => Left(f), (data) => Right(AuthorDashboardOverview.fromJson(data)));
  }

  @override
  Future<Either<Failure, List<FollowerGrowthPoint>>> getFollowerGrowth(String authorId, {int days = 30}) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/dashboard/$authorId/follower-growth',
      queryParameters: {'days': days},
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.map((e) => FollowerGrowthPoint.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, FollowerDemographics>> getFollowerDemographics(String authorId) async {
    final result = await _api.get<Map<String, dynamic>>('${ApiConstants.analytics}/dashboard/$authorId/follower-demographics');
    return result.fold((f) => Left(f), (data) => Right(FollowerDemographics.fromJson(data)));
  }

  @override
  Future<Either<Failure, List<WorkPerformance>>> getWorksPerformance(String authorId) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/dashboard/$authorId/works-performance',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.map((e) => WorkPerformance.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, List<ActivityItem>>> getRecentActivity(String authorId, {int limit = 20}) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/dashboard/$authorId/recent-activity',
      queryParameters: {'limit': limit},
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.map((e) => ActivityItem.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  // ── Legacy Author Analytics ─────────────────────────────────

  @override
  Future<Either<Failure, AuthorOverview>> getOverview(String authorId) async {
    final result = await _api.get<Map<String, dynamic>>('${ApiConstants.analytics}/author/$authorId/overview');
    return result.fold((f) => Left(f), (data) => Right(AuthorOverview.fromJson(data)));
  }

  @override
  Future<Either<Failure, List<ChapterAnalytics>>> getChapterAnalytics(String authorId) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/author/$authorId/chapters',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.map((e) => ChapterAnalytics.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }

  @override
  Future<Either<Failure, SessionAnalytics>> getSessionAnalytics(String authorId) async {
    final result = await _api.get<Map<String, dynamic>>('${ApiConstants.analytics}/author/$authorId/sessions');
    return result.fold((f) => Left(f), (data) => Right(SessionAnalytics.fromJson(data)));
  }

  @override
  Future<Either<Failure, EngagementAnalytics>> getEngagement(String authorId) async {
    final result = await _api.get<Map<String, dynamic>>('${ApiConstants.analytics}/author/$authorId/engagement');
    return result.fold((f) => Left(f), (data) => Right(EngagementAnalytics.fromJson(data)));
  }

  @override
  Future<Either<Failure, List<GenreAnalytics>>> getGenreAnalytics(String authorId) async {
    final result = await _api.get<List<dynamic>>(
      '${ApiConstants.analytics}/author/$authorId/genres',
      fromJson: (data) => data as List<dynamic>,
    );
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.map((e) => GenreAnalytics.fromJson(e as Map<String, dynamic>)).toList()),
    );
  }
}
