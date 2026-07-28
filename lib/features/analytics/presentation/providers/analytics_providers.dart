import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../domain/repositories/i_analytics_repository.dart';

final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  final api = ref.read(contentApiClientProvider);
  return AnalyticsRepositoryImpl(api);
});

// ── Story Analytics Providers ──────────────────────────────────

final storyOverviewProvider = FutureProvider.family<StoryOverview, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryOverview(workId);
  return result.fold((f) => throw f, (data) => data);
});

final storyVoteTrendProvider = FutureProvider.family<List<VoteTrendPoint>, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryVoteTrend(workId);
  return result.fold((f) => throw f, (data) => data);
});

final storyDemographicsProvider = FutureProvider.family<ReaderDemographics, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryDemographics(workId);
  return result.fold((f) => throw f, (data) => data);
});

final storyChaptersProvider = FutureProvider.family<List<ChapterAnalytics>, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryChapters(workId);
  return result.fold((f) => throw f, (data) => data);
});

final storyPeaksProvider = FutureProvider.family<ReadingPeaksData, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryPeaks(workId);
  return result.fold((f) => throw f, (data) => data);
});

final storyReReadsProvider = FutureProvider.family<List<ReReadPattern>, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryReReads(workId);
  return result.fold((f) => throw f, (data) => data);
});

// ── Author Dashboard Providers ─────────────────────────────────

final authorDashboardOverviewProvider = FutureProvider<AuthorDashboardOverview>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getAuthorDashboardOverview(user.id);
  return result.fold((f) => throw f, (data) => data);
});

final followerGrowthProvider = FutureProvider<List<FollowerGrowthPoint>>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getFollowerGrowth(user.id);
  return result.fold((f) => throw f, (data) => data);
});

final followerDemographicsProvider = FutureProvider<FollowerDemographics>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getFollowerDemographics(user.id);
  return result.fold((f) => throw f, (data) => data);
});

final worksPerformanceProvider = FutureProvider<List<WorkPerformance>>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getWorksPerformance(user.id);
  return result.fold((f) => throw f, (data) => data);
});

final recentActivityProvider = FutureProvider<List<ActivityItem>>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getRecentActivity(user.id);
  return result.fold((f) => throw f, (data) => data);
});

// ── Legacy Author Analytics ────────────────────────────────────

final authorOverviewProvider = FutureProvider<AuthorOverview>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getOverview(user.id);
  return result.fold((f) => throw f, (data) => data);
});

final chapterAnalyticsProvider = FutureProvider<List<ChapterAnalytics>>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getChapterAnalytics(user.id);
  return result.fold((f) => throw f, (data) => data);
});

final sessionAnalyticsProvider = FutureProvider<SessionAnalytics>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getSessionAnalytics(user.id);
  return result.fold((f) => throw f, (data) => data);
});

final engagementAnalyticsProvider = FutureProvider<EngagementAnalytics>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getEngagement(user.id);
  return result.fold((f) => throw f, (data) => data);
});

final genreAnalyticsProvider = FutureProvider<List<GenreAnalytics>>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getGenreAnalytics(user.id);
  return result.fold((f) => throw f, (data) => data);
});

// ── Detailed Per-Story Mining Providers ────────────────────────

final storyHeatmapProvider = FutureProvider.family<List<HeatmapChapter>, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryHeatmap(workId);
  return result.fold((f) => throw f, (data) => data);
});

final storySentimentProvider = FutureProvider.family<List<SentimentChapter>, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStorySentiment(workId);
  return result.fold((f) => throw f, (data) => data);
});

final storyDemographicCrossProvider = FutureProvider.family<DemographicCrossData, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryDemographicCross(workId);
  return result.fold((f) => throw f, (data) => data);
});

final storyReaderPreferencesProvider = FutureProvider.family<ReaderPreferencesData, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryReaderPreferences(workId);
  return result.fold((f) => throw f, (data) => data);
});

final storyRetentionProvider = FutureProvider.family<List<RetentionPoint>, String>((ref, workId) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final result = await repo.getStoryRetention(workId);
  return result.fold((f) => throw f, (data) => data);
});

// ── Reading Session Tracker ────────────────────────────────────

class ReadingSessionTracker {
  final IAnalyticsRepository _repo;
  String? _sessionId;
  DateTime? _startTime;
  String? _currentWorkId;
  String? _currentChapterId;

  ReadingSessionTracker(this._repo);

  String? get sessionId => _sessionId;

  Future<void> startSession({required String workId, required String chapterId}) async {
    _currentWorkId = workId;
    _currentChapterId = chapterId;
    _startTime = DateTime.now();
    final platformName = Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'web';
    final result = await _repo.startSession(workId: workId, chapterId: chapterId, deviceType: 'mobile', platform: platformName);
    result.fold((_) {}, (sessionId) => _sessionId = sessionId);
  }

  Future<void> endSession() async {
    if (_sessionId == null || _startTime == null) return;
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    await _repo.endSession(_sessionId!, duration);
    _sessionId = null;
    _startTime = null;
  }

  Future<void> sendChapterRead({required double readProgress, required int timeSpentSeconds}) async {
    if (_currentWorkId == null || _currentChapterId == null) return;
    await _repo.chapterRead(workId: _currentWorkId!, chapterId: _currentChapterId!, readProgress: readProgress, timeSpentSeconds: timeSpentSeconds);
  }
}
