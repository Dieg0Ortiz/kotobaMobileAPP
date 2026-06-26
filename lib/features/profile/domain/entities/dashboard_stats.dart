import 'package:equatable/equatable.dart';

/// Entidad de dominio: Estadísticas del dashboard de autor.
class DashboardStats extends Equatable {
  final int activeReaders;
  final int totalReads;
  final int publishedWorks;
  final int followers;
  final List<EngagementPoint> engagementData;
  final DateTime? nextPublicationDeadline;

  const DashboardStats({
    required this.activeReaders,
    required this.totalReads,
    required this.publishedWorks,
    required this.followers,
    this.engagementData = const [],
    this.nextPublicationDeadline,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activeReaders: json['activeReaders'] as int? ?? 0,
      totalReads: json['totalReads'] as int? ?? 0,
      publishedWorks: json['publishedWorks'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      nextPublicationDeadline: json['nextPublicationDeadline'] != null
          ? DateTime.parse(json['nextPublicationDeadline'] as String)
          : null,
      engagementData: (json['engagementData'] as List<dynamic>?)
              ?.map((e) => EngagementPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [activeReaders, totalReads, publishedWorks];
}

/// Punto de datos para el gráfico de engagement.
class EngagementPoint extends Equatable {
  final DateTime date;
  final double value;

  const EngagementPoint({required this.date, required this.value});

  factory EngagementPoint.fromJson(Map<String, dynamic> json) {
    return EngagementPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }

  @override
  List<Object> get props => [date, value];
}
