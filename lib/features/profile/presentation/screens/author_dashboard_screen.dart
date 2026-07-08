import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../providers/profile_providers.dart';
import '../widgets/stat_card.dart';

/// Dashboard de analíticas para el autor.
class AuthorDashboardScreen extends ConsumerWidget {
  const AuthorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(authorDashboardProvider);
    final c = KotobaColors.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppStrings.authorDashboard, style: KotobaTypography.labelMd.copyWith(color: c.onSurface)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () { if (context.canPop()) context.pop(); },
        ),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumen Global', style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
              const SizedBox(height: 16),
              // Grid de estadísticas
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    label: 'Lecturas Totales',
                    value: stats.totalReads.toString(),
                    icon: Icons.visibility,
                  ),
                  StatCard(
                    label: 'Lectores Activos',
                    value: stats.activeReaders.toString(),
                    icon: Icons.group,
                  ),
                  StatCard(
                    label: 'Obras Publicadas',
                    value: stats.publishedWorks.toString(),
                    icon: Icons.menu_book,
                  ),
                  StatCard(
                    label: 'Seguidores',
                    value: stats.followers.toString(),
                    icon: Icons.person_add,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text('Vistas (Últimos 7 días)',
                  style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
              const SizedBox(height: 24),
              // Gráfico (fl_chart)
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: stats.engagementData.length > 10
                              ? (stats.engagementData.length / 5).ceil().toDouble()
                              : 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= stats.engagementData.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${stats.engagementData[idx].date.day}',
                                style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: stats.engagementData.asMap().entries.map((e) =>
                          FlSpot(e.key.toDouble(), e.value.value),
                        ).toList(),
                        isCurved: true,
                        color: c.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: c.primary.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
