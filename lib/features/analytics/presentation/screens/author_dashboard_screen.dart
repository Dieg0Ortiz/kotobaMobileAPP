import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../domain/entities/analytics_entities.dart';
import '../providers/analytics_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class AuthorDashboardScreen extends ConsumerWidget {
  const AuthorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KotobaColors.of(context);
    final overviewAsync = ref.watch(authorDashboardOverviewProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final userName = profileAsync.valueOrNull?.username ?? 'Autor';

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: c.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Dashboard', style: TextStyle(fontFamily: 'Noto Serif JP', fontSize: 20, fontWeight: FontWeight.bold, color: c.onSurface)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: c.onSurfaceVariant),
            onPressed: () {
              ref.invalidate(authorDashboardOverviewProvider);
              ref.invalidate(followerGrowthProvider);
              ref.invalidate(followerDemographicsProvider);
              ref.invalidate(worksPerformanceProvider);
              ref.invalidate(recentActivityProvider);
            },
          ),
        ],
      ),
      body: overviewAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: c.onSurfaceVariant))),
        data: (overview) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(authorDashboardOverviewProvider);
            ref.invalidate(followerGrowthProvider);
            ref.invalidate(followerDemographicsProvider);
            ref.invalidate(worksPerformanceProvider);
            ref.invalidate(recentActivityProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HOLA, $userName', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: c.primary)),
                const SizedBox(height: 8),
                Text('Tu Panel de Autor', style: TextStyle(fontFamily: 'Noto Serif JP', fontSize: 28, fontWeight: FontWeight.bold, color: c.onSurface)),
                const SizedBox(height: 20),

                // ── Stats Grid ──
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _StatTile(icon: Icons.people, label: 'Seguidores', value: '${overview.totalFollowers}', color: const Color(0xFF2196F3), c: c),
                    _StatTile(icon: Icons.visibility, label: 'Visitas totales', value: '${overview.totalViews}', color: const Color(0xFF4CAF50), c: c),
                    _StatTile(icon: Icons.library_books, label: 'Obras', value: '${overview.publishedWorks}', color: c.primary, c: c),
                    _StatTile(icon: Icons.book, label: 'Total obras', value: '${overview.workCount}', color: const Color(0xFF9C27B0), c: c),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Follower Growth ──
                _buildSection('CRECIMIENTO DE SEGUIDORES', _FollowerGrowthChart(c: c)),
                const SizedBox(height: 24),

                // ── Follower Demographics ──
                _buildSection('DEMOGRAFÍA DE SEGUIDORES', _FollowerDemographicsSection(c: c)),
                const SizedBox(height: 24),

                // ── Works Performance ──
                _buildSection('RENDIMIENTO DE OBRAS', _WorksPerformanceSection(c: c)),
                const SizedBox(height: 24),

                // ── Recent Activity ──
                _buildSection('ACTIVIDAD RECIENTE', _RecentActivitySection(c: c)),
                const SizedBox(height: 24),

                // ── Income Section ──
                _buildSection('INGRESOS', _IncomeSection(ref: ref, c: c)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
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
}

// ── Follower Growth Chart ──────────────────────────────────────

class _FollowerGrowthChart extends ConsumerWidget {
  final KotobaColors c;
  const _FollowerGrowthChart({required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growthAsync = ref.watch(followerGrowthProvider);
    return growthAsync.when(
      loading: () => const SizedBox(height: 180, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin datos de crecimiento', c),
      data: (points) {
        if (points.isEmpty) return _empty('Aún no hay seguidores registrados', c);
        final maxY = points.map((p) => p.count).fold<int>(0, (a, b) => a > b ? a : b);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${points.fold<int>(0, (s, p) => s + p.count)} nuevos en 30 días', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface)),
                  Icon(Icons.trending_up, color: c.primary, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
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
                      spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble())).toList(),
                      isCurved: true,
                      color: c.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(colors: [c.primary.withValues(alpha: 0.2), c.primary.withValues(alpha: 0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                    ),
                  ],
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Follower Demographics ──────────────────────────────────────

class _FollowerDemographicsSection extends ConsumerWidget {
  final KotobaColors c;
  const _FollowerDemographicsSection({required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoAsync = ref.watch(followerDemographicsProvider);
    return demoAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin datos demográficos', c),
      data: (demo) {
        if (demo.countries.isEmpty && demo.ageRanges.isEmpty) return _empty('Aún no hay seguidores', c);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (demo.countries.isNotEmpty) ...[
                Text('Por País', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface)),
                const SizedBox(height: 8),
                ...demo.countries.take(8).map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 100, child: Text(d.label, style: TextStyle(fontSize: 12, color: c.onSurface), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: demo.countries.first.count > 0 ? d.count / demo.countries.first.count : 0,
                            minHeight: 8,
                            backgroundColor: c.outlineVariant.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(c.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${d.count}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurfaceVariant)),
                    ],
                  ),
                )),
              ],
              if (demo.ageRanges.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Por Edad', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.onSurface)),
                const SizedBox(height: 8),
                ...demo.ageRanges.take(6).map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 100, child: Text(d.label, style: TextStyle(fontSize: 12, color: c.onSurface), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: demo.ageRanges.first.count > 0 ? d.count / demo.ageRanges.first.count : 0,
                            minHeight: 8,
                            backgroundColor: c.outlineVariant.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(const Color(0xFFD9735A)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${d.count}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurfaceVariant)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Works Performance ──────────────────────────────────────────

class _WorksPerformanceSection extends ConsumerWidget {
  final KotobaColors c;
  const _WorksPerformanceSection({required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(worksPerformanceProvider);
    return worksAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin datos de obras', c),
      data: (works) {
        if (works.isEmpty) return _empty('No hay obras publicadas', c);
        return Column(
          children: works.map((w) => GestureDetector(
            onTap: () => context.push('/works/${w.workId}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(w.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.onSurface), overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: w.status == 'completed' ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : c.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(w.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: w.status == 'completed' ? const Color(0xFF4CAF50) : c.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Metric(icon: Icons.visibility, value: '${w.views}', label: 'Visitas', c: c),
                      _Metric(icon: Icons.thumb_up, value: '${w.upvotes}', label: 'Upvotes', c: c),
                      _Metric(icon: Icons.people, value: '${w.uniqueReaders}', label: 'Lectores', c: c),
                      _Metric(icon: Icons.check_circle, value: '${w.completionRate}%', label: 'Completado', c: c),
                    ],
                  ),
                ],
              ),
            ),
          )).toList(),
        );
      },
    );
  }
}

// ── Recent Activity ────────────────────────────────────────────

class _RecentActivitySection extends ConsumerWidget {
  final KotobaColors c;
  const _RecentActivitySection({required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);
    return activityAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin actividad', c),
      data: (activities) {
        if (activities.isEmpty) return _empty('No hay actividad reciente', c);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: activities.take(10).map((a) {
              IconData icon;
              Color color;
              String text;
              switch (a.type) {
                case 'vote':
                  icon = a.detail == 'upvote' ? Icons.thumb_up : Icons.thumb_down;
                  color = a.detail == 'upvote' ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
                  text = '${a.username} votó ${a.detail == "upvote" ? "positivo" : "negativo"} en "${a.workTitle}"';
                  break;
                case 'follower':
                  icon = Icons.person_add;
                  color = const Color(0xFF2196F3);
                  text = '${a.username} te siguió';
                  break;
                case 'comment':
                  icon = Icons.comment;
                  color = const Color(0xFFFF9800);
                  text = '${a.username} comentó en "${a.workTitle}"';
                  break;
                default:
                  icon = Icons.info;
                  color = c.onSurfaceVariant;
                  text = '${a.username} - ${a.type}';
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: c.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ── Income Section ─────────────────────────────────────────────

class _IncomeSection extends ConsumerWidget {
  final WidgetRef ref;
  final KotobaColors c;
  const _IncomeSection({required this.ref, required this.c});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceProvider);
    return balanceAsync.when(
      loading: () => const SizedBox(height: 80, child: Center(child: KotobaLoading())),
      error: (_, __) => _empty('Sin datos de ingresos', c),
      data: (balance) {
        final available = (balance['balance'] ?? 0).toDouble();
        final totalEarned = (balance['total_earned'] ?? 0).toDouble();
        final pending = (balance['pending_payout'] ?? 0).toDouble();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _IncomeItem(label: 'Disponible', value: '\$${available.toStringAsFixed(2)}', icon: Icons.account_balance_wallet, c: c),
                  _IncomeItem(label: 'Total ganado', value: '\$${totalEarned.toStringAsFixed(2)}', icon: Icons.trending_up, c: c),
                  _IncomeItem(label: 'Pendiente', value: '\$${pending.toStringAsFixed(2)}', icon: Icons.hourglass_bottom, c: c),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.payments, size: 18),
                  onPressed: available > 0 ? () => _requestPayout(ref, c, context) : null,
                  label: const Text('SOLICITAR PAGO'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD9735A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _requestPayout(WidgetRef ref, KotobaColors c, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: const Text('Solicitar pago'),
        content: const Text('Se enviará tu saldo disponible a tu cuenta de PayPal configurada. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(requestPayoutProvider.future).then((msg) {
                ref.invalidate(balanceProvider);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              });
            },
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────

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

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final KotobaColors c;
  const _Metric({required this.icon, required this.value, required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 14, color: c.primary),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.onSurface)),
        Text(label, style: TextStyle(fontSize: 9, color: c.onSurfaceVariant)),
      ],
    );
  }
}

class _IncomeItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final KotobaColors c;
  const _IncomeItem({required this.label, required this.value, required this.icon, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFD9735A)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontFamily: 'Noto Serif JP', fontSize: 18, fontWeight: FontWeight.bold, color: c.onSurface)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: c.onSurfaceVariant)),
      ],
    );
  }
}

Widget _empty(String msg, KotobaColors c) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: c.surfaceLowest, borderRadius: BorderRadius.circular(8)),
    child: Center(child: Text(msg, style: TextStyle(color: c.onSurfaceVariant, fontSize: 13))),
  );
}
