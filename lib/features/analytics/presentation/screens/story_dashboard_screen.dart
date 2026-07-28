import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../domain/entities/analytics_entities.dart';
import '../providers/analytics_providers.dart';

class StoryDashboardScreen extends ConsumerWidget {
  final String workId;
  final String? workTitle;
  const StoryDashboardScreen({required this.workId, this.workTitle, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KotobaColors.of(context);
    final overviewAsync = ref.watch(storyOverviewProvider(workId));

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: c.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(
          workTitle ?? 'Dashboard',
          style: TextStyle(fontFamily: 'Noto Serif JP', fontSize: 18, fontWeight: FontWeight.bold, color: c.onSurface),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: overviewAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: c.onSurfaceVariant))),
        data: (overview) => RefreshIndicator(
          onRefresh: () async { ref.invalidate(storyOverviewProvider(workId)); },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(overview, c),
                const SizedBox(height: 20),
                _buildStatGrid(overview, c),
                const SizedBox(height: 24),
                _buildSection('TENDENCIA DE VOTOS', _VoteTrendChart(workId: workId, c: c)),
                const SizedBox(height: 24),
                _buildSection('DEMOGRAFÍA DE LECTORES', _DemographicsSection(workId: workId, c: c)),
                const SizedBox(height: 24),
                _buildSection('ANÁLISIS POR CAPÍTULO', _ChaptersSection(workId: workId, c: c)),
                const SizedBox(height: 24),
                _buildSection('PICOS DE LECTURA', _PeaksSection(workId: workId, c: c)),
                const SizedBox(height: 24),
                _buildSection('RE-LECTURAS', _ReReadsSection(workId: workId, c: c)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StoryOverview o, KotobaColors c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: o.genres.map((g) => Chip(
              label: Text(g, style: TextStyle(fontSize: 11, color: c.primary)),
              backgroundColor: c.primary.withValues(alpha: 0.1),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: '${o.totalViews}', label: 'Visitas', c: c),
              _StatItem(value: '${o.uniqueReaders}', label: 'Lectores', c: c),
              _StatItem(value: '${o.totalChapters}', label: 'Capítulos', c: c),
              _StatItem(value: '${o.completionRate}%', label: 'Completado', c: c),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(StoryOverview o, KotobaColors c) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _StatTile(icon: Icons.thumb_up, label: 'Upvotes', value: '${o.upvotes}', color: const Color(0xFF4CAF50), c: c),
        _StatTile(icon: Icons.thumb_down, label: 'Downvotes', value: '${o.downvotes}', color: const Color(0xFFF44336), c: c),
        _StatTile(icon: Icons.star, label: 'Rating', value: '${o.rating}%', color: c.primary, c: c),
        _StatTile(icon: Icons.people, label: 'Seguidores obra', value: '${o.totalFollowers}', color: const Color(0xFF2196F3), c: c),
        _StatTile(icon: Icons.timer, label: 'Tiempo prom.', value: _formatDuration(o.avgTimeSpent), color: const Color(0xFF9C27B0), c: c),
        _StatTile(icon: Icons.trending_up, label: 'Progreso prom.', value: '${(o.avgProgress * 100).toInt()}%', color: const Color(0xFFFF9800), c: c),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF735B28))),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    return '${seconds ~/ 60}m ${seconds % 60}s';
  }
}

// ── Vote Trend Chart ───────────────────────────────────────────

class _VoteTrendChart extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _VoteTrendChart({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(storyVoteTrendProvider(workId));
    return trendAsync.when(
      loading: () => const SizedBox(height: 150, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin datos de votos', c),
      data: (points) {
        if (points.isEmpty) return _empty('Sin votos registrados', c);
        final maxY = points.map((p) => p.upvotes > p.downvotes ? p.upvotes : p.downvotes).fold<int>(0, (a, b) => a > b ? a : b);
        return SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (maxY / 4).clamp(1, double.infinity), getDrawingHorizontalLine: (v) => FlLine(color: c.outlineVariant.withValues(alpha: 0.1), strokeWidth: 1)),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < points.length && idx % 5 == 0) return Padding(padding: const EdgeInsets.only(top: 4), child: Text(points[idx].date.substring(5), style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)));
                return const SizedBox.shrink();
              })),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.upvotes.toDouble())).toList(),
                isCurved: true, color: const Color(0xFF4CAF50), barWidth: 3, dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF4CAF50).withValues(alpha: 0.2), const Color(0xFF4CAF50).withValues(alpha: 0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              ),
              LineChartBarData(
                spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.downvotes.toDouble())).toList(),
                isCurved: true, color: const Color(0xFFF44336), barWidth: 3, dotData: const FlDotData(show: false),
              ),
            ],
          )),
        );
      },
    );
  }
}

// ── Demographics Section ───────────────────────────────────────

class _DemographicsSection extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _DemographicsSection({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoAsync = ref.watch(storyDemographicsProvider(workId));
    return demoAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin datos demográficos', c),
      data: (demo) {
        if (demo.countries.isEmpty && demo.ageRanges.isEmpty) return _empty('Aún no hay lectores registrados', c);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (demo.countries.isNotEmpty) ...[
              Text('Por País', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface)),
              const SizedBox(height: 8),
              _buildBarChart(demo.countries.map((d) => _BarData(d.label, d.count)).toList(), c),
              const SizedBox(height: 16),
            ],
            if (demo.ageRanges.isNotEmpty) ...[
              Text('Por Edad', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface)),
              const SizedBox(height: 8),
              _buildBarChart(demo.ageRanges.map((d) => _BarData(d.label, d.count)).toList(), c),
            ],
          ],
        );
      },
    );
  }
}

// ── Chapters Section ───────────────────────────────────────────

class _ChaptersSection extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _ChaptersSection({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(storyChaptersProvider(workId));
    return chaptersAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin datos de capítulos', c),
      data: (chapters) {
        if (chapters.isEmpty) return _empty('No hay capítulos', c);
        return Column(
          children: chapters.map((ch) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text('#${ch.orderNumber}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c.primary)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ch.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface))),
                    Text('${ch.views} lecturas', style: TextStyle(fontSize: 12, color: c.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MiniMetric(label: 'Completado', value: '${(ch.completionRate * 100).toInt()}%', c: c),
                    _MiniMetric(label: 'Tiempo prom.', value: _fmtDur(ch.avgTimeSpent), c: c),
                    _MiniMetric(label: 'Abandono', value: '${(ch.dropOffRate * 100).toInt()}%', c: c),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(value: ch.completionRate, minHeight: 5, backgroundColor: c.outlineVariant.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(c.primary)),
                ),
              ],
            ),
          )).toList(),
        );
      },
    );
  }

  String _fmtDur(int s) => s < 60 ? '${s}s' : '${s ~/ 60}m ${s % 60}s';
}

// ── Peaks Section ──────────────────────────────────────────────

class _PeaksSection extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _PeaksSection({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peaksAsync = ref.watch(storyPeaksProvider(workId));
    return peaksAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin datos de picos', c),
      data: (peaks) {
        if (peaks.hourlyPeaks.every((h) => h.count == 0) && peaks.chapterPeaks.isEmpty) {
          return _empty('Aún no hay suficientes datos', c);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Horas Pico', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface)),
            const SizedBox(height: 8),
            _buildBarChart(
              peaks.hourlyPeaks.map((h) => _BarData('${h.hour}h', h.count)).toList(),
              c,
            ),
            const SizedBox(height: 16),
            if (peaks.chapterPeaks.isNotEmpty) ...[
              Text('Capítulos Más Leídos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface)),
              const SizedBox(height: 8),
              ...peaks.chapterPeaks.take(5).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text('#${p.orderNumber}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.primary)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(p.title, style: TextStyle(fontSize: 13, color: c.onSurface))),
                    Text('${p.count}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurfaceVariant)),
                  ],
                ),
              )),
            ],
          ],
        );
      },
    );
  }
}

// ── Re-Reads Section ───────────────────────────────────────────

class _ReReadsSection extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _ReReadsSection({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reReadsAsync = ref.watch(storyReReadsProvider(workId));
    return reReadsAsync.when(
      loading: () => const SizedBox(height: 80, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin datos de re-lecturas', c),
      data: (reReads) {
        if (reReads.isEmpty) return _empty('No hay re-lecturas registradas', c);
        return Column(
          children: reReads.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('#${r.orderNumber}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c.primary)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(r.title, style: TextStyle(fontSize: 13, color: c.onSurface))),
                Text('${r.reReadCount} re-lecturas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary)),
              ],
            ),
          )).toList(),
        );
      },
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value, label;
  final KotobaColors c;
  const _StatItem({required this.value, required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Noto Serif JP', fontSize: 22, fontWeight: FontWeight.bold, color: c.onSurface)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final KotobaColors c;
  const _StatTile({required this.icon, required this.label, required this.value, required this.color, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.onSurface)),
              Text(label, style: TextStyle(fontSize: 10, color: c.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label, value;
  final KotobaColors c;
  const _MiniMetric({required this.label, required this.value, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.onSurface)),
        Text(label, style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)),
      ],
    );
  }
}

class _BarData {
  final String label;
  final int value;
  _BarData(this.label, this.value);
}

Widget _buildBarChart(List<_BarData> data, KotobaColors c) {
  if (data.isEmpty) return const SizedBox.shrink();
  final maxVal = data.map((d) => d.value).fold<int>(0, (a, b) => a > b ? a : b);
  return SizedBox(
    height: 160,
    child: BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxVal > 0 ? maxVal * 1.2 : 10,
      barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(getTooltipItem: (g, i, rod, _) => BarTooltipItem('${rod.toY.toInt()}', TextStyle(color: c.onSurface, fontSize: 11)))),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final idx = v.toInt();
          if (idx < data.length) {
            final label = data[idx].label;
            return Padding(padding: const EdgeInsets.only(top: 4), child: Text(label.length > 6 ? label.substring(0, 6) : label, style: TextStyle(fontSize: 8, color: c.onSurfaceVariant)));
          }
          return const SizedBox.shrink();
        })),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: data.asMap().entries.map((e) => BarChartGroupData(
        x: e.key,
        barRods: [BarChartRodData(toY: e.value.value.toDouble(), color: c.primary, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
      )).toList(),
    )),
  );
}

Widget _empty(String msg, KotobaColors c) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
    child: Center(child: Text(msg, style: TextStyle(color: c.onSurfaceVariant, fontSize: 13))),
  );
}
