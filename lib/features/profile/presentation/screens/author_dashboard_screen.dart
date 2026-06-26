import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.authorDashboard, style: KotobaTypography.labelMd),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
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
              Text('Resumen Global', style: KotobaTypography.headlineMd),
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
                  style: KotobaTypography.headlineMd),
              const SizedBox(height: 24),
              // Gráfico (fl_chart)
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
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
                          interval: 1,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 30),
                          FlSpot(1, 40),
                          FlSpot(2, 35),
                          FlSpot(3, 50),
                          FlSpot(4, 45),
                          FlSpot(5, 70),
                          FlSpot(6, 65),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.15),
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
