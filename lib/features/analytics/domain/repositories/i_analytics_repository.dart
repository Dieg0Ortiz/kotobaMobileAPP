import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/analytics_entities.dart';

abstract class IAnalyticsRepository {
  // Tracking
  Future<Either<Failure, String>> startSession({required String workId, required String chapterId, String? deviceType, String? platform});
  Future<Either<Failure, void>> endSession(String sessionId, int durationSeconds);
  Future<Either<Failure, void>> chapterRead({required String workId, required String chapterId, required double readProgress, required int timeSpentSeconds});

  // Story analytics
  Future<Either<Failure, StoryOverview>> getStoryOverview(String workId);
  Future<Either<Failure, List<VoteTrendPoint>>> getStoryVoteTrend(String workId, {int days});
  Future<Either<Failure, ReaderDemographics>> getStoryDemographics(String workId);
  Future<Either<Failure, List<ChapterAnalytics>>> getStoryChapters(String workId);
  Future<Either<Failure, ReadingPeaksData>> getStoryPeaks(String workId);
  Future<Either<Failure, List<ReReadPattern>>> getStoryReReads(String workId);

  // Author dashboard
  Future<Either<Failure, AuthorDashboardOverview>> getAuthorDashboardOverview(String authorId);
  Future<Either<Failure, List<FollowerGrowthPoint>>> getFollowerGrowth(String authorId, {int days});
  Future<Either<Failure, FollowerDemographics>> getFollowerDemographics(String authorId);
  Future<Either<Failure, List<WorkPerformance>>> getWorksPerformance(String authorId);
  Future<Either<Failure, List<ActivityItem>>> getRecentActivity(String authorId, {int limit});

  // Legacy author analytics
  Future<Either<Failure, AuthorOverview>> getOverview(String authorId);
  Future<Either<Failure, List<ChapterAnalytics>>> getChapterAnalytics(String authorId);
  Future<Either<Failure, SessionAnalytics>> getSessionAnalytics(String authorId);
  Future<Either<Failure, EngagementAnalytics>> getEngagement(String authorId);
  Future<Either<Failure, List<GenreAnalytics>>> getGenreAnalytics(String authorId);

  // Detailed per-story mining
  Future<Either<Failure, List<HeatmapChapter>>> getStoryHeatmap(String workId);
  Future<Either<Failure, List<SentimentChapter>>> getStorySentiment(String workId);
  Future<Either<Failure, DemographicCrossData>> getStoryDemographicCross(String workId);
  Future<Either<Failure, ReaderPreferencesData>> getStoryReaderPreferences(String workId);
  Future<Either<Failure, List<RetentionPoint>>> getStoryRetention(String workId);
}
