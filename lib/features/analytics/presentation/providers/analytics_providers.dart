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

// ── Analytics queries ────────────────────────────────────────────

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

// ── Tracking helper (used by reader) ────────────────────────────

class ReadingSessionTracker {
  final IAnalyticsRepository _repo;
  String? _sessionId;
  DateTime? _startTime;
  String? _currentWorkId;
  String? _currentChapterId;

  ReadingSessionTracker(this._repo);

  String? get sessionId => _sessionId;

  Future<void> startSession({
    required String workId,
    required String chapterId,
  }) async {
    _currentWorkId = workId;
    _currentChapterId = chapterId;
    _startTime = DateTime.now();

    final platformName = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : 'web';

    final result = await _repo.startSession(
      workId: workId,
      chapterId: chapterId,
      deviceType: 'mobile',
      platform: platformName,
    );
    result.fold(
      (_) {},
      (sessionId) => _sessionId = sessionId,
    );
  }

  Future<void> endSession() async {
    if (_sessionId == null || _startTime == null) return;
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    await _repo.endSession(_sessionId!, duration);
    _sessionId = null;
    _startTime = null;
  }

  Future<void> sendChapterRead({
    required double readProgress,
    required int timeSpentSeconds,
  }) async {
    if (_currentWorkId == null || _currentChapterId == null) return;
    await _repo.chapterRead(
      workId: _currentWorkId!,
      chapterId: _currentChapterId!,
      readProgress: readProgress,
      timeSpentSeconds: timeSpentSeconds,
    );
  }
}
