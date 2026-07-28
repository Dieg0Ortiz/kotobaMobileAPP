import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../domain/entities/analytics_entities.dart';
import '../providers/analytics_providers.dart';

class StoryDetailedAnalyticsScreen extends ConsumerWidget {
  final String workId;
  final String workTitle;
  const StoryDetailedAnalyticsScreen({required this.workId, required this.workTitle, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KotobaColors.of(context);
    final overviewAsync = ref.watch(storyOverviewProvider(workId));

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back, color: c.onSurface), onPressed: () => Navigator.pop(context)),
          title: Text(workTitle, style: TextStyle(fontFamily: 'Noto Serif JP', fontSize: 18, fontWeight: FontWeight.bold, color: c.onSurface), overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: c.onSurfaceVariant),
              onPressed: () {
                ref.invalidate(storyOverviewProvider(workId));
                ref.invalidate(storyHeatmapProvider(workId));
                ref.invalidate(storySentimentProvider(workId));
                ref.invalidate(storyDemographicCrossProvider(workId));
                ref.invalidate(storyReaderPreferencesProvider(workId));
                ref.invalidate(storyRetentionProvider(workId));
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: c.primary,
            unselectedLabelColor: c.onSurfaceVariant,
            indicatorColor: c.primary,
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            tabs: const [
              Tab(text: 'RESUMEN'),
              Tab(text: 'ABANDONO'),
              Tab(text: 'SENTIMIENTO'),
              Tab(text: 'DEMOGRAFÍA'),
              Tab(text: 'RETENCIÓN'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(workId: workId, c: c),
            _HeatmapTab(workId: workId, c: c),
            _SentimentTab(workId: workId, c: c),
            _DemographicTab(workId: workId, c: c),
            _RetentionTab(workId: workId, c: c),
          ],
        ),
      ),
    );
  }
}

// ── Tab 0: Overview ─────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _OverviewTab({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(storyOverviewProvider(workId));
    return overviewAsync.when(
      loading: () => const Center(child: KotobaLoading()),
      error: (e, _) => _empty('Error: $e', c),
      data: (o) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('MÉTRICAS GENERALES', c),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.0,
              children: [
                _statTile(Icons.visibility, '${o.totalViews}', 'Lecturas', const Color(0xFF4CAF50), c),
                _statTile(Icons.people, '${o.uniqueReaders}', 'Lectores únicos', const Color(0xFF2196F3), c),
                _statTile(Icons.thumb_up, '${o.upvotes}', 'Upvotes', const Color(0xFF8BC34A), c),
                _statTile(Icons.thumb_down, '${o.downvotes}', 'Downvotes', const Color(0xFFF44336), c),
                _statTile(Icons.star, '${o.rating}%', 'Rating', const Color(0xFFFFC107), c),
                _statTile(Icons.book, '${o.totalChapters}', 'Capítulos', c.primary, c),
                _statTile(Icons.trending_up, '${(o.avgProgress * 100).toInt()}%', 'Progreso promedio', const Color(0xFF9C27B0), c),
                _statTile(Icons.check_circle, '${o.completionRate}%', 'Completado', const Color(0xFF00BCD4), c),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: Heatmap / Abandon ────────────────────────────────────

class _HeatmapTab extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _HeatmapTab({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(storyHeatmapProvider(workId));
    return heatmapAsync.when(
      loading: () => const Center(child: KotobaLoading()),
      error: (e, _) => _empty('Error: $e', c),
      data: (chapters) {
        if (chapters.isEmpty) return _empty('Sin datos de lectura aún', c);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('MAPA DE CALOR — ABANDONO POR CAPÍTULO', c),
              const SizedBox(height: 8),
              Text('Muestra en qué segmento los lectores abandonan cada capítulo', style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
              const SizedBox(height: 16),
              ...chapters.map((ch) => _heatmapChapterCard(ch, c)),
            ],
          ),
        );
      },
    );
  }

  Widget _heatmapChapterCard(HeatmapChapter ch, KotobaColors c) {
    final maxReaders = ch.segments.isNotEmpty ? ch.segments.first.readersAtSegment : 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Cap. ${ch.orderNumber}: ${ch.title}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface), overflow: TextOverflow.ellipsis)),
              Text('${ch.totalReaders} lectores', style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 10),
          ...ch.segments.map((seg) {
            final ratio = maxReaders > 0 ? seg.readersAtSegment / maxReaders : 0.0;
            final intensity = (1.0 - ratio).clamp(0.0, 1.0);
            final barColor = Color.lerp(const Color(0xFF4CAF50), const Color(0xFFF44336), intensity);
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(width: 55, child: Text(seg.range, style: TextStyle(fontSize: 10, color: c.onSurfaceVariant))),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 10,
                        backgroundColor: c.outlineVariant.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(barColor!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(width: 30, child: Text('${seg.readersAtSegment}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c.onSurface), textAlign: TextAlign.right)),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text('Progreso promedio: ${(ch.avgProgress * 100).toInt()}% · Tiempo: ${ch.avgTimeSeconds}s', style: TextStyle(fontSize: 10, color: c.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Tab 2: Sentiment ────────────────────────────────────────────

class _SentimentTab extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _SentimentTab({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentimentAsync = ref.watch(storySentimentProvider(workId));
    return sentimentAsync.when(
      loading: () => const Center(child: KotobaLoading()),
      error: (e, _) => _empty('Error: $e', c),
      data: (chapters) {
        if (chapters.isEmpty || chapters.every((ch) => ch.totalComments == 0)) return _empty('Sin comentarios para analizar', c);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('ANÁLISIS DE SENTIMIENTO POR CAPÍTULO', c),
              const SizedBox(height: 8),
              Text('Clasificación automática de comentarios en positivo / negativo / neutral', style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chapters.map((ch) => ch.totalComments.toDouble()).fold<double>(1, (a, b) => a > b ? a : b),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < chapters.length) return Padding(padding: const EdgeInsets.only(top: 4), child: Text('${chapters[idx].orderNumber}', style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)));
                        return const SizedBox.shrink();
                      },
                    )),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: chapters.asMap().entries.where((e) => e.value.totalComments > 0).map((e) {
                    final ch = e.value;
                    return BarChartGroupData(x: e.key, barRods: [
                      BarChartRodData(toY: ch.positiveCount.toDouble(), color: const Color(0xFF4CAF50), width: 12),
                      BarChartRodData(toY: ch.neutralCount.toDouble(), color: const Color(0xFF9E9E9E), width: 12),
                      BarChartRodData(toY: ch.negativeCount.toDouble(), color: const Color(0xFFF44336), width: 12),
                    ]);
                  }).toList(),
                )),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendDot(const Color(0xFF4CAF50), 'Positivo', c),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFF9E9E9E), 'Neutral', c),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFFF44336), 'Negativo', c),
                ],
              ),
              const SizedBox(height: 16),
              ...chapters.where((ch) => ch.totalComments > 0).map((ch) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cap. ${ch.orderNumber}: ${ch.title}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _miniStat('${ch.totalComments} total', c.onSurfaceVariant, c),
                        const SizedBox(width: 8),
                        _miniStat('${ch.positiveCount} positivos', const Color(0xFF4CAF50), c),
                        const SizedBox(width: 8),
                        _miniStat('${ch.negativeCount} negativos', const Color(0xFFF44336), c),
                        const SizedBox(width: 8),
                        _miniStat('Score: ${ch.sentimentScore > 0 ? '+' : ''}${ch.sentimentScore.toStringAsFixed(2)}', ch.sentimentScore >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336), c),
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}

// ── Tab 3: Demographic Cross ───────────────────────────────────

class _DemographicTab extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _DemographicTab({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoAsync = ref.watch(storyDemographicCrossProvider(workId));
    return demoAsync.when(
      loading: () => const Center(child: KotobaLoading()),
      error: (e, _) => _empty('Error: $e', c),
      data: (data) {
        if (data.ageGroups.isEmpty && data.countries.isEmpty) return _empty('Sin datos demográficos', c);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('CRUCE DEMOGRAFÍA × COMPORTAMIENTO', c),
              const SizedBox(height: 8),
              Text('Cómo se comporta cada segmento demográfico en tu obra', style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
              const SizedBox(height: 16),
              if (data.ageGroups.isNotEmpty) ...[
                _sectionLabel('POR RANGO DE EDAD', c),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: BarChart(BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: data.ageGroups.map((g) => g.readerCount.toDouble()).fold<double>(1, (a, b) => a > b ? a : b),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < data.ageGroups.length) return Padding(padding: const EdgeInsets.only(top: 4), child: Text(data.ageGroups[idx].label, style: TextStyle(fontSize: 8, color: c.onSurfaceVariant)));
                          return const SizedBox.shrink();
                        },
                      )),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: data.ageGroups.asMap().entries.map((e) {
                      return BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(toY: e.value.readerCount.toDouble(), color: c.primary, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                      ]);
                    }).toList(),
                  )),
                ),
                const SizedBox(height: 12),
                ...data.ageGroups.map((g) => _demographicRow(g, c)),
                const SizedBox(height: 20),
              ],
              if (data.countries.isNotEmpty) ...[
                _sectionLabel('POR PAÍS', c),
                const SizedBox(height: 8),
                ...data.countries.map((g) => _demographicRow(g, c, isCountry: true)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _demographicRow(DemographicCrossGroup g, KotobaColors c, {bool isCountry = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(isCountry ? Icons.public : Icons.person, size: 16, color: c.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(g.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurface))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${g.readerCount} lectores', style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
              Text('${(g.avgProgress * 100).toInt()}% progreso · ${g.completionRate}% completado', style: TextStyle(fontSize: 10, color: c.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tab 4: Retention Curve ─────────────────────────────────────

class _RetentionTab extends ConsumerWidget {
  final String workId;
  final KotobaColors c;
  const _RetentionTab({required this.workId, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retentionAsync = ref.watch(storyRetentionProvider(workId));
    return retentionAsync.when(
      loading: () => const Center(child: KotobaLoading()),
      error: (e, _) => _empty('Error: $e', c),
      data: (points) {
        if (points.isEmpty) return _empty('Se necesitan al menos 2 capítulos', c);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('CURVA DE RETENCIÓN ENTRE CAPÍTULOS', c),
              const SizedBox(height: 8),
              Text('% de lectores que pasan de un capítulo al siguiente', style: TextStyle(fontSize: 11, color: c.onSurfaceVariant)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (v) => FlLine(color: c.outlineVariant.withValues(alpha: 0.1), strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < points.length) return Padding(padding: const EdgeInsets.only(top: 4), child: Text('${points[idx].chapterOrder}', style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)));
                        return const SizedBox.shrink();
                      },
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)),
                    )),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 105,
                  lineBarsData: [
                    LineChartBarData(
                      spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.retentionRate.toDouble())).toList(),
                      isCurved: true,
                      color: c.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, idx) => FlDotCirclePainter(radius: 4, color: c.primary, strokeColor: Colors.white, strokeWidth: 2),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(colors: [c.primary.withValues(alpha: 0.2), c.primary.withValues(alpha: 0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                    ),
                  ],
                )),
              ),
              const SizedBox(height: 16),
              ...points.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Expanded(child: Text('Cap. ${p.chapterOrder}: ${p.chapterTitle}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurface), overflow: TextOverflow.ellipsis)),
                    Text('${p.retentionRate}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: p.retentionRate >= 70 ? const Color(0xFF4CAF50) : p.retentionRate >= 40 ? const Color(0xFFFFC107) : const Color(0xFFF44336))),
                    Text(' → ${p.nextChapterTitle}', style: TextStyle(fontSize: 10, color: c.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}

// ── Shared Widgets ──────────────────────────────────────────────

Widget _sectionLabel(String text, KotobaColors c) {
  return Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: c.primary));
}

Widget _empty(String msg, KotobaColors c) {
  return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(msg, style: TextStyle(color: c.onSurfaceVariant, fontSize: 13))));
}

Widget _statTile(IconData icon, String value, String label, Color color, KotobaColors c) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c.onSurface)),
            Text(label, style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)),
          ],
        ),
      ],
    ),
  );
}

Widget _miniStat(String text, Color color, [KotobaColors? c]) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
  );
}

Widget _legendDot(Color color, String label, KotobaColors c) {
  return Row(
    children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: c.onSurfaceVariant)),
    ],
  );
}
