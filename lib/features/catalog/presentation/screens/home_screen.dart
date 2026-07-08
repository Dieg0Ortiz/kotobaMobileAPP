import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_avatar.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/catalog_providers.dart';
import '../widgets/featured_card.dart';
import '../widgets/work_card.dart';

/// Pantalla principal: Discovery Feed.
///
/// Hero con logo, tendencias en carrusel horizontal, selección para ti,
/// nuevos autores, todo con mock data.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingWorksProvider);
    final newAuthorsAsync = ref.watch(newAuthorsProvider);
    final c = KotobaColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Hero Section ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kotoba',
                      style: KotobaTypography.displayXL.copyWith(
                        color: c.primary,
                      ),
                    ),
                    Text(
                      '言葉',
                      style: KotobaTypography.headlineMd.copyWith(
                        color: c.primaryDim,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu historia, sin límites.',
                      style: KotobaTypography.bodyMd.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tendencias ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.trending,
                        style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
                    TextButton(
                      onPressed: () => context.go('/search'),
                      child: Text(
                        AppStrings.seeAll,
                        style: KotobaTypography.labelSm
                            .copyWith(color: c.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: trendingAsync.when(
                loading: () => const SizedBox(
                  height: 280,
                  child: Center(child: KotobaLoading()),
                ),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (works) => SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: works.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, i) => WorkCard(
                      work: works[i],
                      onTap: () => context.push('/works/${works[i].id}'),
                    ),
                  ),
                ),
              ),
            ),

            // ── Selección Para Ti ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 32, bottom: 16),
                child: Text(
                  AppStrings.selectionForYou,
                  style: KotobaTypography.headlineMd.copyWith(color: c.onSurface),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: trendingAsync.when(
                loading: () => const SizedBox(
                  height: 320,
                  child: Center(child: KotobaLoading()),
                ),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (works) => works.isNotEmpty
                    ? FeaturedCard(
                        work: works.first,
                        onTap: () => context.push('/works/${works.first.id}'),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // ── Nuevos Autores ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 32, bottom: 16),
                child: Text(
                  AppStrings.newAuthors,
                  style: KotobaTypography.headlineMd.copyWith(color: c.onSurface),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: newAuthorsAsync.when(
                loading: () => const SizedBox(
                  height: 80,
                  child: Center(child: KotobaLoading()),
                ),
                error: (e, _) => const SizedBox.shrink(),
                data: (authors) {
                  if (authors.isEmpty) return const SizedBox.shrink();
                  
                  return SizedBox(
                    height: 85,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: authors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, i) {
                        final author = authors[i];
                        return GestureDetector(
                          onTap: () => context.push('/users/${author.id}'),
                          child: Column(
                            children: [
                              KotobaAvatar(
                                imageUrl: author.avatarUrl,
                                size: KotobaAvatarSize.md,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                author.username,
                                style: KotobaTypography.labelXs.copyWith(color: c.onSurface),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
