import 'package:equatable/equatable.dart';

class AuthorOverview extends Equatable {
  final int totalReads;
  final int activeReaders;
  final int avgSessionDuration;
  final int totalChaptersRead;
  final int completionRate;
  final int totalFollowers;

  const AuthorOverview({
    required this.totalReads,
    required this.activeReaders,
    required this.avgSessionDuration,
    required this.totalChaptersRead,
    required this.completionRate,
    required this.totalFollowers,
  });

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
  List<Object?> get props => [totalReads, activeReaders, avgSessionDuration];
}

class ChapterAnalytics extends Equatable {
  final String chapterId;
  final String title;
  final int orderNumber;
  final int views;
  final double avgProgress;
  final int avgTimeSpent;
  final double completionRate;

  const ChapterAnalytics({
    required this.chapterId,
    required this.title,
    required this.orderNumber,
    required this.views,
    required this.avgProgress,
    required this.avgTimeSpent,
    required this.completionRate,
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
    );
  }

  @override
  List<Object?> get props => [chapterId, title, views];
}

class SessionAnalytics extends Equatable {
  final List<HourlyPoint> hourlyDistribution;
  final List<DailyPoint> dailyDistribution;
  final List<DevicePoint> deviceBreakdown;
  final int avgDuration;

  const SessionAnalytics({
    required this.hourlyDistribution,
    required this.dailyDistribution,
    required this.deviceBreakdown,
    required this.avgDuration,
  });

  factory SessionAnalytics.fromJson(Map<String, dynamic> json) {
    return SessionAnalytics(
      hourlyDistribution: (json['hourlyDistribution'] as List<dynamic>?)
              ?.map((e) => HourlyPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyDistribution: (json['dailyDistribution'] as List<dynamic>?)
              ?.map((e) => DailyPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deviceBreakdown: (json['deviceBreakdown'] as List<dynamic>?)
              ?.map((e) => DevicePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      avgDuration: json['avgDuration'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [hourlyDistribution, dailyDistribution, avgDuration];
}

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

class EngagementAnalytics extends Equatable {
  final List<ReReadPattern> reReadPatterns;
  final List<DropOffPoint> dropOffPoints;

  const EngagementAnalytics({
    required this.reReadPatterns,
    required this.dropOffPoints,
  });

  factory EngagementAnalytics.fromJson(Map<String, dynamic> json) {
    return EngagementAnalytics(
      reReadPatterns: (json['reReadPatterns'] as List<dynamic>?)
              ?.map((e) => ReReadPattern.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dropOffPoints: (json['dropOffPoints'] as List<dynamic>?)
              ?.map((e) => DropOffPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [reReadPatterns, dropOffPoints];
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
