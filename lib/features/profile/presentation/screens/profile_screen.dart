import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
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

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(e.toString(), style: const TextStyle(color: AppColors.error)),
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

            // 2. Sección: Historias (Carrusel Horizontal)
            SliverToBoxAdapter(
              child: _UserWorksCarousel(userId: user.id, username: user.username, worksCount: user.worksCount),
            ),

            // 4. Sección: Siguiendo / Autores Similares
            const SliverToBoxAdapter(
              child: SimilarAuthorsCard(),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Divider(color: AppColors.outlineVariant),
              ),
            ),

            // 5. Sección: Géneros que escribe (desde tags reales de las obras)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _UserTags(userId: user.id),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Divider(color: AppColors.outlineVariant),
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
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(tag, style: KotobaTypography.labelXs),
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
                      decoration: const BoxDecoration(
                        color: AppColors.action,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurface),
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
                      style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant),
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
                  'Historias de @${username}',
                  style: KotobaTypography.headlineMd,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 4, bottom: 16),
          child: Text(
            '$displayedCount Historias publicadas',
            style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant),
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
                  return HorizontalWorkCard(work: works[index]);
                },
              ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Divider(color: AppColors.outlineVariant),
        ),
      ],
    );
  }
}
