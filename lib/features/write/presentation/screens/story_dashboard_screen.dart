import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../profile/presentation/widgets/stat_card.dart';

class StoryDashboardScreen extends StatelessWidget {
  final String storyId;

  const StoryDashboardScreen({super.key, required this.storyId});

  Widget _glassCard(KotobaColors c, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF131318).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: c.onSurface.withValues(alpha: 0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analíticas de la Historia',
          style: KotobaTypography.headlineMd.copyWith(color: c.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _glassCard(
          c,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DASHBOARD DE LA HISTORIA',
                      style: KotobaTypography.labelSm.copyWith(
                        color: c.primary,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.analytics_outlined, color: c.primary, size: 20),
                  ],
                ),
              ),
              
              // Stats Grid
              LayoutBuilder(
                builder: (context, gridConstraints) {
                  final double width = gridConstraints.maxWidth;
                  final int crossAxisCount = width > 500 ? 2 : 1;
                  final double childAspectRatio = width > 500 ? 1.6 : 2.5;
                  
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                    children: [
                      const StatCard(
                        label: 'Active Readers',
                        value: '142', // Mock data for this specific story
                        icon: Icons.visibility,
                        trend: '+8%',
                        isPositive: true,
                      ),
                      const StatCard(
                        label: 'Total Reads',
                        value: '1,053', // Mock data
                        icon: Icons.menu_book,
                        trend: '+12%',
                        isPositive: true,
                      ),
                    ],
                  );
                }
              ),
              
              const SizedBox(height: 32),
              
              // Chart Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reader Engagement',
                    style: TextStyle(
                      fontFamily: 'Noto Serif JP',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: c.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.outlineVariant.withValues(alpha: 0.3)),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                        ),
                        child: Text('7D', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c.onSurfaceVariant)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF735B28), // Gold/Brown Active
                          border: Border.all(color: const Color(0xFF735B28)),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                        ),
                        child: const Text('30D', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: c.outlineVariant.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 5),
                          FlSpot(1, 10),
                          FlSpot(2, 8),
                          FlSpot(3, 20),
                          FlSpot(4, 25),
                          FlSpot(5, 40),
                          FlSpot(6, 60),
                        ],
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: const Color(0xFFD9735A), // Terracotta
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD9735A).withValues(alpha: 0.2),
                              const Color(0xFFD9735A).withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
