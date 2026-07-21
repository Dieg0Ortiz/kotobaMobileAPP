import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../providers/profile_providers.dart';
import '../widgets/stat_card.dart';

class AuthorDashboardScreen extends ConsumerWidget {
  const AuthorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(authorDashboardProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final c = KotobaColors.of(context);

    final userName = profileAsync.valueOrNull?.username ?? 'A.K. Varela';

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: c.onSurfaceVariant),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.history, color: c.onSurfaceVariant),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24, left: 16),
            child: Center(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF735B28), // Gold/Brown
                  side: const BorderSide(color: Color(0xFF735B28)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('PUBLISH', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (stats) => LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  const Text(
                    'AUTHOR DASHBOARD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF735B28), // Gold
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Panel de autor',
                            style: TextStyle(
                              fontFamily: 'Noto Serif JP',
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: c.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bienvenido, $userName',
                            style: TextStyle(
                              fontSize: 16,
                              color: c.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/write'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('NUEVO CAPÍTULO', style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9735A), // Terracotta
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Divider(color: c.outlineVariant.withValues(alpha: 0.2), height: 1),
                  const SizedBox(height: 32),

                  // ── Grid de estadísticas ──
                  LayoutBuilder(
                    builder: (context, gridConstraints) {
                      final double width = gridConstraints.maxWidth;
                      final int crossAxisCount = width > 900 ? 4 : (width > 500 ? 2 : 1);
                      final double childAspectRatio = width > 900 ? 1.4 : 1.6;
                      
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: childAspectRatio,
                        children: [
                          const StatCard(
                            label: 'Active Readers',
                            value: '2,847', // Mock for UI as requested
                            icon: Icons.visibility,
                            trend: '+12%',
                            isPositive: true,
                          ),
                          const StatCard(
                            label: 'Total Reads',
                            value: '48,320', // Mock
                            icon: Icons.menu_book,
                            trend: '+5%',
                            isPositive: true,
                          ),
                          StatCard(
                            label: 'Published Works',
                            value: stats.publishedWorks.toString(),
                            icon: Icons.library_books,
                            trend: '- 0',
                            isPositive: false,
                          ),
                          const StatCard(
                            label: 'Followers',
                            value: '1,204', // Mock
                            icon: Icons.people,
                            trend: '+24',
                            isPositive: true,
                          ),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 48),

                  // ── Income Section ──
                  _buildIncomeSection(ref, c),
                  const SizedBox(height: 48),

                  // ── Bottom Area (Chart + Next Publication) ──
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildChartCard(c, stats)),
                        const SizedBox(width: 32),
                        Expanded(flex: 1, child: _buildNextPublicationCard(c)),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChartCard(c, stats),
                        const SizedBox(height: 32),
                        _buildNextPublicationCard(c),
                      ],
                    ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIncomeSection(WidgetRef ref, KotobaColors c) {
    final balanceAsync = ref.watch(balanceProvider);
    return balanceAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: KotobaLoading())),
      error: (_, __) => const SizedBox.shrink(),
      data: (balance) {
        final available = (balance['balance'] ?? 0).toStringAsFixed(2);
        final totalEarned = (balance['total_earned'] ?? 0).toStringAsFixed(2);
        final pending = (balance['pending_payout'] ?? 0).toStringAsFixed(2);
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: c.surfaceLowest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: c.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TUS INGRESOS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFF735B28),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildIncomeStat(c, 'Disponible', '\$$available', Icons.account_balance_wallet),
                  const SizedBox(width: 48),
                  _buildIncomeStat(c, 'Total ganado', '\$$totalEarned', Icons.trending_up),
                  const SizedBox(width: 48),
                  _buildIncomeStat(c, 'Pendiente', '\$$pending', Icons.hourglass_bottom),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 44,
                child: FilledButton.icon(
                  icon: const Icon(Icons.payments, size: 18),
                  onPressed: (balance['balance'] ?? 0) > 0 ? () => _requestPayout(ref, c) : null,
                  label: const Text('SOLICITAR PAGO'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD9735A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _requestPayout(WidgetRef ref, KotobaColors c) {
    showDialog(
      context: ref.context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: const Text('Solicitar pago'),
        content: const Text('Se moverá tu saldo disponible a pendiente de pago. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(requestPayoutProvider.future).then((_) {
                ref.invalidate(balanceProvider);
                ScaffoldMessenger.of(ref.context).showSnackBar(
                  const SnackBar(content: Text('Pago solicitado correctamente')),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(ref.context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              });
            },
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeStat(KotobaColors c, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFD9735A)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Noto Serif JP',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: c.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: c.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildChartCard(KotobaColors c, dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: c.surfaceLowest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reader Engagement',
                style: TextStyle(
                  fontFamily: 'Noto Serif JP',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: c.onSurface,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: c.outlineVariant.withValues(alpha: 0.3)),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                    ),
                    child: Text('7D', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.onSurfaceVariant)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF735B28), // Gold/Brown Active
                      border: Border.all(color: const Color(0xFF735B28)),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                    child: const Text('30D', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 250,
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
                      FlSpot(0, 10),
                      FlSpot(1, 15),
                      FlSpot(2, 20),
                      FlSpot(3, 45),
                      FlSpot(4, 55),
                      FlSpot(5, 50),
                      FlSpot(6, 20),
                      FlSpot(7, 10),
                      FlSpot(8, 60),
                      FlSpot(9, 100),
                      FlSpot(10, 80),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFFD9735A), // Terracotta
                    barWidth: 4,
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
    );
  }

  Widget _buildNextPublicationCard(KotobaColors c) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: c.surfaceLowest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.2)),
        gradient: LinearGradient(
          colors: [
            c.surfaceLowest,
            const Color(0xFFD9735A).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEXT PUBLICATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF735B28),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'El Eco del\nVacío',
            style: TextStyle(
              fontFamily: 'Noto Serif JP',
              fontSize: 32,
              height: 1.1,
              fontWeight: FontWeight.bold,
              color: c.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capítulo 12: La Resonancia',
            style: TextStyle(
              fontSize: 14,
              color: c.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 48),
          Divider(color: c.outlineVariant.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeBlock(c, '02', 'DÍAS'),
              Text(':', style: TextStyle(fontSize: 24, color: c.outlineVariant)),
              _buildTimeBlock(c, '14', 'HRS'),
              Text(':', style: TextStyle(fontSize: 24, color: c.outlineVariant)),
              _buildTimeBlock(c, '45', 'MIN'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(KotobaColors c, String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontFamily: 'Noto Serif JP',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: c.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: c.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
