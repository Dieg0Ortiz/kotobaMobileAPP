import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/domain/entities/work.dart';
import '../providers/profile_providers.dart';
import '../widgets/horizontal_work_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_sidebar_widgets.dart';
import '../widgets/settings_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final c = KotobaColors.of(context);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(e.toString(), style: TextStyle(color: c.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(logoutUseCaseProvider).execute();
                  ref.read(authStateProvider.notifier).state = false;
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
        data: (user) => CustomScrollView(
          slivers: [
            // 1. Cabecera
            SliverToBoxAdapter(
              child: ProfileHeader(
                user: user,
                onSettingsTap: () => _showSettings(context),
              ),
            ),

            // 1.5. Dashboard de autor (solo si es autor)
            if (user.isAuthor)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.bar_chart, size: 18),
                    onPressed: () => context.push('/author/dashboard'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD9735A),
                      side: const BorderSide(color: Color(0xFFD9735A)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    label: const Text('Dashboard de Autor', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

            // 2. Sección: Historias (Carrusel Horizontal)
            SliverToBoxAdapter(
              child: _UserWorksCarousel(userId: user.id, username: user.username, worksCount: user.worksCount),
            ),

            // 4. Sección: Siguiendo / Autores Similares
            const SliverToBoxAdapter(
              child: SimilarAuthorsCard(),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Divider(color: c.outlineVariant),
              ),
            ),

            // 5. Sección: Géneros que escribe (desde tags reales de las obras)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _UserTags(userId: user.id),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Divider(color: c.outlineVariant),
              ),
            ),

            // 6. Sección: Actividad Reciente
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _UserActivity(userId: user.id),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

/// Tags extraídos de las obras del usuario (los más usados).
class _UserTags extends ConsumerWidget {
  final String userId;
  const _UserTags({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(userWorksProvider(userId));
    final c = KotobaColors.of(context);

    return worksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (works) {
        final tagCount = <String, int>{};
        for (final work in works) {
          for (final tag in work.tags) {
            tagCount[tag] = (tagCount[tag] ?? 0) + 1;
          }
        }
        if (tagCount.isEmpty) return const SizedBox.shrink();
        final sorted = tagCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topTags = sorted.take(6).map((e) => e.key).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GÉNEROS QUE ESCRIBE',
              style: KotobaTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: c.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: c.outlineVariant),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(tag, style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant)),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

/// Actividad reciente basada en datos reales de las obras.
class _UserActivity extends ConsumerWidget {
  final String userId;
  const _UserActivity({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(userWorksProvider(userId));
    final c = KotobaColors.of(context);

    return worksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (works) {
        if (works.isEmpty) return const SizedBox.shrink();
        final sorted = List<Work>.from(works)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        final recent = sorted.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACTIVIDAD RECIENTE',
              style: KotobaTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: c.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...recent.map((work) {
              final timeAgo = _timeAgo(work.updatedAt);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4, right: 12),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: c.action,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
                          children: [
                            const TextSpan(
                              text: 'Actualizó ',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: work.title,
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Carrusel de obras del usuario conectado al backend real.
class _UserWorksCarousel extends ConsumerWidget {
  final String userId;
  final String username;
  final int worksCount;

  const _UserWorksCarousel({
    required this.userId,
    required this.username,
    required this.worksCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(userWorksProvider(userId));
    final c = KotobaColors.of(context);
    final displayedCount = worksAsync.maybeWhen(
      data: (works) => works.length,
      orElse: () => worksCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Historias de @$username',
                  style: KotobaTypography.headlineMd.copyWith(color: c.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, color: c.onSurfaceVariant),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 4, bottom: 16),
          child: Text(
            '$displayedCount Historias publicadas',
            style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
          ),
        ),
        worksAsync.when(
          loading: () => const SizedBox(
            height: 220,
            child: Center(child: KotobaLoading()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (works) {
            if (works.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text('Aún no has publicado historias'),
                ),
              );
            }
            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24),
                itemCount: works.length,
                itemBuilder: (context, index) {
                  return HorizontalWorkCard(
                    work: works[index],
                    onTap: () => context.go('/works/${works[index].id}'),
                  );
                },
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Divider(color: c.outlineVariant),
        ),
      ],
    );
  }
}
