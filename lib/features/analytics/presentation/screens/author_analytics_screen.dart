import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../domain/entities/analytics_entities.dart';
import '../providers/analytics_providers.dart';

class AuthorAnalyticsScreen extends ConsumerStatefulWidget {
  const AuthorAnalyticsScreen({super.key});

  @override
  ConsumerState<AuthorAnalyticsScreen> createState() => _AuthorAnalyticsScreenState();
}

class _AuthorAnalyticsScreenState extends ConsumerState<AuthorAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Analíticas',
          style: TextStyle(
            fontFamily: 'Noto Serif JP',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: c.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: c.primary,
          unselectedLabelColor: c.onSurfaceVariant,
          indicatorColor: c.primary,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(text: 'Capítulos'),
            Tab(text: 'Sesiones'),
            Tab(text: 'Engagement'),
            Tab(text: 'Géneros'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChaptersTab(c: c),
          _SessionsTab(c: c),
          _EngagementTab(c: c),
          _GenresTab(c: c),
        ],
      ),
    );
  }
}

// ── Chapters Tab ────────────────────────────────────────────────

class _ChaptersTab extends ConsumerWidget {
  final KotobaColors c;
  const _ChaptersTab({required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chapterAnalyticsProvider);
    return chaptersAsync.when(
      loading: () => const Center(child: KotobaLoading()),
      error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: c.onSurfaceVariant))),
      data: (chapters) {
        if (chapters.isEmpty) {
          return Center(
            child: Text('No hay datos de capítulos aún', style: TextStyle(color: c.onSurfaceVariant)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chapters.length,
          itemBuilder: (_, i) => _ChapterAnalyticsCard(chapter: chapters[i], c: c),
        );
      },
    );
  }
}

class _ChapterAnalyticsCard extends StatelessWidget {
  final ChapterAnalytics chapter;
  final KotobaColors c;
  const _ChapterAnalyticsCard({required this.chapter, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${chapter.orderNumber}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chapter.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(label: 'Lecturas', value: '${chapter.views}', c: c),
              _MiniStat(
                label: 'Completado',
                value: '${(chapter.completionRate * 100).toInt()}%',
                c: c,
              ),
              _MiniStat(
                label: 'Tiempo prom.',
                value: _formatDuration(chapter.avgTimeSpent),
                c: c,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: chapter.avgProgress,
              minHeight: 6,
              backgroundColor: c.outlineVariant.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(c.primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Progreso promedio: ${(chapter.avgProgress * 100).toInt()}%',
            style: TextStyle(fontSize: 11, color: c.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final KotobaColors c;
  const _MiniStat({required this.label, required this.value, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Noto Serif JP',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: c.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
      ],
    );
  }
}

// ── Sessions Tab ────────────────────────────────────────────────

class _SessionsTab extends ConsumerWidget {
  final KotobaColors c;
  const _SessionsTab({required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionAnalyticsProvider);
    return sessionsAsync.when(
      loading: () => const Center(child: KotobaLoading()),
      error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: c.onSurfaceVariant))),
      data: (sessions) {
        if (sessions.hourlyDistribution.every((h) => h.count == 0) &&
            sessions.dailyDistribution.every((d) => d.count == 0)) {
          return Center(
            child: Text('No hay datos de sesiones aún', style: TextStyle(color: c.onSurfaceVariant)),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Horas pico', c),
              const SizedBox(height: 8),
              _buildBarChart(
                sessions.hourlyDistribution.map((h) => FlSpot(h.hour.toDouble(), h.count.toDouble())).toList(),
                c,
                maxY: sessions.hourlyDistribution.map((h) => h.count.toDouble()).fold<double>(0, (a, b) => a > b ? a : b),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Días de la semana', c),
              const SizedBox(height: 8),
              _buildBarChart(
                sessions.dailyDistribution.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble())).toList(),
                c,
                maxY: sessions.dailyDistribution.map((d) => d.count.toDouble()).fold<double>(0, (a, b) => a > b ? a : b),
                labels: sessions.dailyDistribution.map((d) => d.day).toList(),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Dispositivos', c),
              const SizedBox(height: 8),
              _buildDeviceBreakdown(sessions.deviceBreakdown, c),
              const SizedBox(height: 24),
              _buildSectionTitle('Duración promedio', c),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surfaceLowest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, color: c.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      _formatDuration(sessions.avgDuration),
                      style: TextStyle(
                        fontFamily: 'Noto Serif JP',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: c.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}

// ── Engagement Tab ──────────────────────────────────────────────

class _EngagementTab extends ConsumerWidget {
  final KotobaColors c;
  const _EngagementTab({required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engagementAsync = ref.watch(engagementAnalyticsProvider);
    return engagementAsync.when(
      loading: () => const Center(child: KotobaLoading()),
      error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: c.onSurfaceVariant))),
      data: (engagement) {
        if (engagement.reReadPatterns.isEmpty && engagement.dropOffPoints.isEmpty) {
          return Center(
            child: Text('No hay datos de engagement aún', style: TextStyle(color: c.onSurfaceVariant)),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Capítulos más re-leídos', c),
              const SizedBox(height: 8),
              if (engagement.reReadPatterns.isEmpty)
                _emptyState('No hay re-lecturas registradas', c)
              else
                ...engagement.reReadPatterns.map((p) => _ReReadTile(pattern: p, c: c)),
              const SizedBox(height: 24),
              _buildSectionTitle('Puntos de abandono', c),
              const SizedBox(height: 8),
              if (engagement.dropOffPoints.isEmpty)
                _emptyState('No hay datos de abandono', c)
              else
                _buildDropOffChart(engagement.dropOffPoints, c),
            ],
          ),
        );
      },
    );
  }
}

class _ReReadTile extends StatelessWidget {
  final ReReadPattern pattern;
  final KotobaColors c;
  const _ReReadTile({required this.pattern, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('#${pattern.orderNumber}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(pattern.title, style: TextStyle(fontSize: 14, color: c.onSurface)),
          ),
          Text(
            '${pattern.reReadCount} re-lecturas',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary),
          ),
        ],
      ),
    );
  }
}

// ── Genres Tab ──────────────────────────────────────────────────

class _GenresTab extends ConsumerWidget {
  final KotobaColors c;
  const _GenresTab({required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(genreAnalyticsProvider);
    return genresAsync.when(
      loading: () => const Center(child: KotobaLoading()),
      error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: c.onSurfaceVariant))),
      data: (genres) {
        if (genres.isEmpty) {
          return Center(
            child: Text('No hay datos de géneros aún', style: TextStyle(color: c.onSurfaceVariant)),
          );
        }
        final maxReads = genres.map((g) => g.reads).fold<int>(0, (a, b) => a > b ? a : b);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: genres.length,
          itemBuilder: (_, i) {
            final g = genres[i];
            final fraction = maxReads > 0 ? g.reads / maxReads : 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.surfaceLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(g.genre, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.onSurface)),
                      Text('${g.reads} lecturas', style: TextStyle(fontSize: 13, color: c.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 8,
                      backgroundColor: c.outlineVariant.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${g.works} obra${g.works != 1 ? 's' : ''}', style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Shared widgets ──────────────────────────────────────────────

Widget _buildSectionTitle(String title, KotobaColors c) {
  return Text(
    title.toUpperCase(),
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      color: c.primary,
    ),
  );
}

Widget _buildBarChart(List<FlSpot> spots, KotobaColors c, {double maxY = 100, List<String>? labels}) {
  return SizedBox(
    height: 180,
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY * 1.2 : 10,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}',
                TextStyle(color: c.onSurface, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (labels != null && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(labels[idx], style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)),
                  );
                }
                if (idx % 3 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${idx}h', style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: spots
            .map((s) => BarChartGroupData(
                  x: s.x.toInt(),
                  barRods: [
                    BarChartRodData(
                      toY: s.y,
                      color: c.primary,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                ))
            .toList(),
      ),
    ),
  );
}

Widget _buildDeviceBreakdown(List<DevicePoint> devices, KotobaColors c) {
  if (devices.isEmpty) return _emptyState('Sin datos', c);
  final total = devices.fold<int>(0, (sum, d) => sum + d.count);
  final colors = [c.primary, const Color(0xFFD9735A), const Color(0xFF735B28)];
  return Wrap(
    spacing: 16,
    runSpacing: 8,
    children: devices.asMap().entries.map((e) {
      final pct = total > 0 ? (e.value.count / total * 100).toInt() : 0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors[e.key % colors.length].withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors[e.key % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('${e.value.device} ($pct%)', style: TextStyle(fontSize: 13, color: c.onSurface)),
          ],
        ),
      );
    }).toList(),
  );
}

Widget _buildDropOffChart(List<DropOffPoint> points, KotobaColors c) {
  return SizedBox(
    height: 200,
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${(rod.toY).toInt()}% abandono',
                TextStyle(color: c.onSurface, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < points.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('#${points[idx].orderNumber}', style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: points
            .map((p) => BarChartGroupData(
                  x: p.orderNumber,
                  barRods: [
                    BarChartRodData(
                      toY: p.dropOffRate * 100,
                      color: const Color(0xFFD9735A),
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                ))
            .toList(),
      ),
    ),
  );
}

Widget _emptyState(String msg, KotobaColors c) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: c.surfaceLowest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Text(msg, style: TextStyle(color: c.onSurfaceVariant)),
    ),
  );
}
