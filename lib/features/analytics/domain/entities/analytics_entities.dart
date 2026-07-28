import 'package:equatable/equatable.dart';

// ── Story Analytics ─────────────────────────────────────────────

class StoryOverview extends Equatable {
  final String workId;
  final String title;
  final List<String> genres;
  final int totalViews;
  final int upvotes;
  final int downvotes;
  final int rating;
  final int totalFollowers;
  final int totalChapters;
  final int uniqueReaders;
  final double avgProgress;
  final int completionRate;
  final int avgTimeSpent;

  const StoryOverview({
    required this.workId,
    required this.title,
    required this.genres,
    required this.totalViews,
    required this.upvotes,
    required this.downvotes,
    required this.rating,
    required this.totalFollowers,
    required this.totalChapters,
    required this.uniqueReaders,
    required this.avgProgress,
    required this.completionRate,
    required this.avgTimeSpent,
  });

  factory StoryOverview.fromJson(Map<String, dynamic> json) {
    return StoryOverview(
      workId: json['workId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      totalViews: json['totalViews'] as int? ?? 0,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      totalFollowers: json['totalFollowers'] as int? ?? 0,
      totalChapters: json['totalChapters'] as int? ?? 0,
      uniqueReaders: json['uniqueReaders'] as int? ?? 0,
      avgProgress: (json['avgProgress'] as num?)?.toDouble() ?? 0.0,
      completionRate: json['completionRate'] as int? ?? 0,
      avgTimeSpent: json['avgTimeSpent'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [workId, totalViews, upvotes];
}

class VoteTrendPoint extends Equatable {
  final String date;
  final int upvotes;
  final int downvotes;
  const VoteTrendPoint({required this.date, required this.upvotes, required this.downvotes});
  factory VoteTrendPoint.fromJson(Map<String, dynamic> json) {
    return VoteTrendPoint(
      date: json['date'] as String? ?? '',
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [date, upvotes, downvotes];
}

class ReaderDemographics extends Equatable {
  final List<DemographicPoint> countries;
  final List<DemographicPoint> ageRanges;
  const ReaderDemographics({required this.countries, required this.ageRanges});
  factory ReaderDemographics.fromJson(Map<String, dynamic> json) {
    return ReaderDemographics(
      countries: (json['countries'] as List<dynamic>?)
          ?.map((e) => DemographicPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      ageRanges: (json['ageRanges'] as List<dynamic>?)
          ?.map((e) => DemographicPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
  @override
  List<Object?> get props => [countries, ageRanges];
}

class DemographicPoint extends Equatable {
  final String label;
  final int count;
  const DemographicPoint({required this.label, required this.count});
  factory DemographicPoint.fromJson(Map<String, dynamic> json) {
    return DemographicPoint(
      label: json['country'] as String? ?? json['range'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [label, count];
}

class ReadingPeak extends Equatable {
  final String title;
  final int orderNumber;
  final int count;
  const ReadingPeak({required this.title, required this.orderNumber, required this.count});
  factory ReadingPeak.fromJson(Map<String, dynamic> json) {
    return ReadingPeak(
      title: json['title'] as String? ?? '',
      orderNumber: json['orderNumber'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [title, orderNumber, count];
}

class ReadingPeaksData extends Equatable {
  final List<HourlyPoint> hourlyPeaks;
  final List<DailyPoint> dailyPeaks;
  final List<ReadingPeak> chapterPeaks;
  const ReadingPeaksData({required this.hourlyPeaks, required this.dailyPeaks, required this.chapterPeaks});
  factory ReadingPeaksData.fromJson(Map<String, dynamic> json) {
    return ReadingPeaksData(
      hourlyPeaks: (json['hourlyPeaks'] as List<dynamic>?)
          ?.map((e) => HourlyPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      dailyPeaks: (json['dailyPeaks'] as List<dynamic>?)
          ?.map((e) => DailyPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      chapterPeaks: (json['chapterPeaks'] as List<dynamic>?)
          ?.map((e) => ReadingPeak.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
  @override
  List<Object?> get props => [hourlyPeaks, dailyPeaks, chapterPeaks];
}

// ── Shared Entities ─────────────────────────────────────────────

class HourlyPoint extends Equatable {
  final int hour;
  final int count;
  const HourlyPoint({required this.hour, required this.count});
  factory HourlyPoint.fromJson(Map<String, dynamic> json) {
    return HourlyPoint(hour: json['hour'] as int? ?? 0, count: json['count'] as int? ?? 0);
  }
  @override
  List<Object?> get props => [hour, count];
}

class DailyPoint extends Equatable {
  final String day;
  final int count;
  const DailyPoint({required this.day, required this.count});
  factory DailyPoint.fromJson(Map<String, dynamic> json) {
    return DailyPoint(day: json['day'] as String? ?? '', count: json['count'] as int? ?? 0);
  }
  @override
  List<Object?> get props => [day, count];
}

class DevicePoint extends Equatable {
  final String device;
  final int count;
  const DevicePoint({required this.device, required this.count});
  factory DevicePoint.fromJson(Map<String, dynamic> json) {
    return DevicePoint(device: json['device'] as String? ?? '', count: json['count'] as int? ?? 0);
  }
  @override
  List<Object?> get props => [device, count];
}

class ChapterAnalytics extends Equatable {
  final String chapterId;
  final String title;
  final int orderNumber;
  final int views;
  final double avgProgress;
  final int avgTimeSpent;
  final double completionRate;
  final double dropOffRate;

  const ChapterAnalytics({
    required this.chapterId,
    required this.title,
    required this.orderNumber,
    required this.views,
    required this.avgProgress,
    required this.avgTimeSpent,
    required this.completionRate,
    this.dropOffRate = 0,
  });

  factory ChapterAnalytics.fromJson(Map<String, dynamic> json) {
    return ChapterAnalytics(
      chapterId: json['chapterId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      orderNumber: json['orderNumber'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      avgProgress: (json['avgProgress'] as num?)?.toDouble() ?? 0.0,
      avgTimeSpent: json['avgTimeSpent'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      dropOffRate: (json['dropOffRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [chapterId, title, views];
}

class ReReadPattern extends Equatable {
  final String title;
  final int orderNumber;
  final int reReadCount;
  const ReReadPattern({required this.title, required this.orderNumber, required this.reReadCount});
  factory ReReadPattern.fromJson(Map<String, dynamic> json) {
    return ReReadPattern(
      title: json['title'] as String? ?? '',
      orderNumber: json['orderNumber'] as int? ?? 0,
      reReadCount: json['reReadCount'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [title, reReadCount];
}

// ── Author Dashboard Entities ───────────────────────────────────

class AuthorDashboardOverview extends Equatable {
  final int publishedWorks;
  final int totalViews;
  final int totalFollowers;
  final int workCount;
  const AuthorDashboardOverview({required this.publishedWorks, required this.totalViews, required this.totalFollowers, required this.workCount});
  factory AuthorDashboardOverview.fromJson(Map<String, dynamic> json) {
    return AuthorDashboardOverview(
      publishedWorks: json['publishedWorks'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      totalFollowers: json['totalFollowers'] as int? ?? 0,
      workCount: json['workCount'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [publishedWorks, totalViews, totalFollowers];
}

class FollowerGrowthPoint extends Equatable {
  final String date;
  final int count;
  const FollowerGrowthPoint({required this.date, required this.count});
  factory FollowerGrowthPoint.fromJson(Map<String, dynamic> json) {
    return FollowerGrowthPoint(
      date: json['date'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [date, count];
}

class FollowerDemographics extends Equatable {
  final List<DemographicPoint> countries;
  final List<DemographicPoint> ageRanges;
  const FollowerDemographics({required this.countries, required this.ageRanges});
  factory FollowerDemographics.fromJson(Map<String, dynamic> json) {
    return FollowerDemographics(
      countries: (json['countries'] as List<dynamic>?)
          ?.map((e) => DemographicPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      ageRanges: (json['ageRanges'] as List<dynamic>?)
          ?.map((e) => DemographicPoint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
  @override
  List<Object?> get props => [countries, ageRanges];
}

class WorkPerformance extends Equatable {
  final String workId;
  final String title;
  final List<String> genres;
  final String status;
  final int views;
  final int upvotes;
  final int downvotes;
  final int rating;
  final int uniqueReaders;
  final int completionRate;
  final int followers;
  const WorkPerformance({required this.workId, required this.title, required this.genres, required this.status, required this.views, required this.upvotes, required this.downvotes, required this.rating, required this.uniqueReaders, required this.completionRate, required this.followers});
  factory WorkPerformance.fromJson(Map<String, dynamic> json) {
    return WorkPerformance(
      workId: json['workId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] as String? ?? '',
      views: json['views'] as int? ?? 0,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      uniqueReaders: json['uniqueReaders'] as int? ?? 0,
      completionRate: json['completionRate'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [workId, title, views];
}

class ActivityItem extends Equatable {
  final String type;
  final String? workId;
  final String? workTitle;
  final String username;
  final String? detail;
  final String createdAt;
  const ActivityItem({required this.type, this.workId, this.workTitle, required this.username, this.detail, required this.createdAt});
  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      type: json['type'] as String? ?? '',
      workId: json['workId'] as String?,
      workTitle: json['workTitle'] as String?,
      username: json['username'] as String? ?? '',
      detail: json['detail'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
  @override
  List<Object?> get props => [type, username, createdAt];
}

// ── Legacy Entities (kept for backwards compat) ─────────────────

class AuthorOverview extends Equatable {
  final int totalReads;
  final int activeReaders;
  final int avgSessionDuration;
  final int totalChaptersRead;
  final int completionRate;
  final int totalFollowers;
  const AuthorOverview({required this.totalReads, required this.activeReaders, required this.avgSessionDuration, required this.totalChaptersRead, required this.completionRate, required this.totalFollowers});
  factory AuthorOverview.fromJson(Map<String, dynamic> json) {
    return AuthorOverview(
      totalReads: json['totalReads'] as int? ?? 0,
      activeReaders: json['activeReaders'] as int? ?? 0,
      avgSessionDuration: json['avgSessionDuration'] as int? ?? 0,
      totalChaptersRead: json['totalChaptersRead'] as int? ?? 0,
      completionRate: json['completionRate'] as int? ?? 0,
      totalFollowers: json['totalFollowers'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [totalReads, activeReaders, totalFollowers];
}

class SessionAnalytics extends Equatable {
  final List<HourlyPoint> hourlyDistribution;
  final List<DailyPoint> dailyDistribution;
  final List<DevicePoint> deviceBreakdown;
  final int avgDuration;
  const SessionAnalytics({required this.hourlyDistribution, required this.dailyDistribution, required this.deviceBreakdown, required this.avgDuration});
  factory SessionAnalytics.fromJson(Map<String, dynamic> json) {
    return SessionAnalytics(
      hourlyDistribution: (json['hourlyDistribution'] as List<dynamic>?)?.map((e) => HourlyPoint.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      dailyDistribution: (json['dailyDistribution'] as List<dynamic>?)?.map((e) => DailyPoint.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      deviceBreakdown: (json['deviceBreakdown'] as List<dynamic>?)?.map((e) => DevicePoint.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      avgDuration: json['avgDuration'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [hourlyDistribution, dailyDistribution, avgDuration];
}

class EngagementAnalytics extends Equatable {
  final List<ReReadPattern> reReadPatterns;
  final List<DropOffPoint> dropOffPoints;
  const EngagementAnalytics({required this.reReadPatterns, required this.dropOffPoints});
  factory EngagementAnalytics.fromJson(Map<String, dynamic> json) {
    return EngagementAnalytics(
      reReadPatterns: (json['reReadPatterns'] as List<dynamic>?)?.map((e) => ReReadPattern.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      dropOffPoints: (json['dropOffPoints'] as List<dynamic>?)?.map((e) => DropOffPoint.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
  @override
  List<Object?> get props => [reReadPatterns, dropOffPoints];
}

class DropOffPoint extends Equatable {
  final String title;
  final int orderNumber;
  final double dropOffRate;
  final double completionRate;
  final int totalReads;
  const DropOffPoint({required this.title, required this.orderNumber, required this.dropOffRate, required this.completionRate, required this.totalReads});
  factory DropOffPoint.fromJson(Map<String, dynamic> json) {
    return DropOffPoint(
      title: json['title'] as String? ?? '',
      orderNumber: json['orderNumber'] as int? ?? 0,
      dropOffRate: (json['dropOffRate'] as num?)?.toDouble() ?? 0.0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      totalReads: json['totalReads'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [title, orderNumber, dropOffRate];
}

class GenreAnalytics extends Equatable {
  final String genre;
  final int reads;
  final int works;
  const GenreAnalytics({required this.genre, required this.reads, required this.works});
  factory GenreAnalytics.fromJson(Map<String, dynamic> json) {
    return GenreAnalytics(
      genre: json['genre'] as String? ?? '',
      reads: json['reads'] as int? ?? 0,
      works: json['works'] as int? ?? 0,
    );
  }
  @override
  List<Object?> get props => [genre, reads, works];
}

// ── Detailed Per-Story Mining Entities ──────────────────────────

class HeatmapChapter {
  final String chapterId;
  final String title;
  final int orderNumber;
  final int totalReaders;
  final List<HeatmapSegment> segments;
  final double avgProgress;
  final int avgTimeSeconds;
  const HeatmapChapter({required this.chapterId, required this.title, required this.orderNumber, required this.totalReaders, required this.segments, required this.avgProgress, required this.avgTimeSeconds});
  factory HeatmapChapter.fromJson(Map<String, dynamic> json) {
    return HeatmapChapter(
      chapterId: json['chapterId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      orderNumber: json['orderNumber'] as int? ?? 0,
      totalReaders: json['totalReaders'] as int? ?? 0,
      segments: (json['segments'] as List<dynamic>?)?.map((e) => HeatmapSegment.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      avgProgress: (json['avgProgress'] as num?)?.toDouble() ?? 0.0,
      avgTimeSeconds: json['avgTimeSeconds'] as int? ?? 0,
    );
  }
}

class HeatmapSegment {
  final String range;
  final int readersAtSegment;
  final int dropOffPercent;
  const HeatmapSegment({required this.range, required this.readersAtSegment, required this.dropOffPercent});
  factory HeatmapSegment.fromJson(Map<String, dynamic> json) {
    return HeatmapSegment(
      range: json['range'] as String? ?? '',
      readersAtSegment: json['readersAtSegment'] as int? ?? 0,
      dropOffPercent: json['dropOffPercent'] as int? ?? 0,
    );
  }
}

class SentimentChapter {
  final String chapterId;
  final String title;
  final int orderNumber;
  final int totalComments;
  final int positiveCount;
  final int negativeCount;
  final int neutralCount;
  final double sentimentScore;
  const SentimentChapter({required this.chapterId, required this.title, required this.orderNumber, required this.totalComments, required this.positiveCount, required this.negativeCount, required this.neutralCount, required this.sentimentScore});
  factory SentimentChapter.fromJson(Map<String, dynamic> json) {
    return SentimentChapter(
      chapterId: json['chapterId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      orderNumber: json['orderNumber'] as int? ?? 0,
      totalComments: json['totalComments'] as int? ?? 0,
      positiveCount: json['positiveCount'] as int? ?? 0,
      negativeCount: json['negativeCount'] as int? ?? 0,
      neutralCount: json['neutralCount'] as int? ?? 0,
      sentimentScore: (json['sentimentScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DemographicCrossData {
  final List<DemographicCrossGroup> ageGroups;
  final List<DemographicCrossGroup> countries;
  const DemographicCrossData({required this.ageGroups, required this.countries});
  factory DemographicCrossData.fromJson(Map<String, dynamic> json) {
    return DemographicCrossData(
      ageGroups: (json['ageGroups'] as List<dynamic>?)?.map((e) => DemographicCrossGroup.fromJson(e as Map<String, dynamic>, isAge: true)).toList() ?? [],
      countries: (json['countries'] as List<dynamic>?)?.map((e) => DemographicCrossGroup.fromJson(e as Map<String, dynamic>, isAge: false)).toList() ?? [],
    );
  }
}

class DemographicCrossGroup {
  final String label;
  final int readerCount;
  final double avgProgress;
  final int completionRate;
  const DemographicCrossGroup({required this.label, required this.readerCount, required this.avgProgress, required this.completionRate});
  factory DemographicCrossGroup.fromJson(Map<String, dynamic> json, {bool isAge = true}) {
    return DemographicCrossGroup(
      label: isAge ? (json['ageRange'] as String? ?? '') : (json['country'] as String? ?? ''),
      readerCount: json['readerCount'] as int? ?? 0,
      avgProgress: (json['avgProgress'] as num?)?.toDouble() ?? 0.0,
      completionRate: json['completionRate'] as int? ?? 0,
    );
  }
}

class ReaderPreferencesData {
  final int expectedReadersPercent;
  final int unexpectedReadersPercent;
  final List<GenreAffinity> genreAffinity;
  const ReaderPreferencesData({required this.expectedReadersPercent, required this.unexpectedReadersPercent, required this.genreAffinity});
  factory ReaderPreferencesData.fromJson(Map<String, dynamic> json) {
    return ReaderPreferencesData(
      expectedReadersPercent: json['expectedReadersPercent'] as int? ?? 0,
      unexpectedReadersPercent: json['unexpectedReadersPercent'] as int? ?? 0,
      genreAffinity: (json['genreAffinity'] as List<dynamic>?)?.map((e) => GenreAffinity.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class GenreAffinity {
  final String genre;
  final int readerCount;
  const GenreAffinity({required this.genre, required this.readerCount});
  factory GenreAffinity.fromJson(Map<String, dynamic> json) {
    return GenreAffinity(genre: json['genre'] as String? ?? '', readerCount: json['readerCount'] as int? ?? 0);
  }
}

class RetentionPoint {
  final int chapterOrder;
  final String chapterTitle;
  final int readersAtChapter;
  final int retainedToNext;
  final int retentionRate;
  final String nextChapterTitle;
  const RetentionPoint({required this.chapterOrder, required this.chapterTitle, required this.readersAtChapter, required this.retainedToNext, required this.retentionRate, required this.nextChapterTitle});
  factory RetentionPoint.fromJson(Map<String, dynamic> json) {
    return RetentionPoint(
      chapterOrder: json['chapterOrder'] as int? ?? 0,
      chapterTitle: json['chapterTitle'] as String? ?? '',
      readersAtChapter: json['readersAtChapter'] as int? ?? 0,
      retainedToNext: json['retainedToNext'] as int? ?? 0,
      retentionRate: json['retentionRate'] as int? ?? 0,
      nextChapterTitle: json['nextChapterTitle'] as String? ?? '',
    );
  }
}
