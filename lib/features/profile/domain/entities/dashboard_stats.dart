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

  @override
  List<Object?> get props => [activeReaders, totalReads, publishedWorks];
}

/// Punto de datos para el gráfico de engagement.
class EngagementPoint extends Equatable {
  final DateTime date;
  final double value;

  const EngagementPoint({required this.date, required this.value});

  @override
  List<Object> get props => [date, value];
}
