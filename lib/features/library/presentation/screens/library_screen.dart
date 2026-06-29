import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../reader/presentation/providers/reader_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(myBookmarksProvider);
    final followingAsync = ref.watch(followingAuthorsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Biblioteca', style: KotobaTypography.headlineMd),
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (works) {
          return CustomScrollView(
            slivers: [

              // ── Sección: Autores Seguidos ───────────────
              followingAsync.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (authors) {
                  if (authors.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  final carousels = <Widget>[];
                  for (final authorData in authors) {
                    final userJson = authorData['user'] as Map<String, dynamic>? ?? {};
                    final worksList = (authorData['works'] as List<dynamic>?)
                        ?.map((w) => Work(
                              id: w['id'] as String,
                              title: w['title'] as String,
                              authorId: w['author_id'] as String? ?? '',
                              authorName: w['author_name'] as String? ?? userJson['username'] as String? ?? '',
                              coverUrl: w['cover_url'] as String?,
                              synopsis: w['synopsis'] as String? ?? '',
                              genre: w['genre'] as String? ?? '',
                              tags: (w['tags'] as List<dynamic>?)?.cast<String>() ?? [],
                              status: w['status'] as String? ?? 'ongoing',
                              chapterCount: w['chapter_count'] as int? ?? 0,
                              wordCount: w['word_count'] as int? ?? 0,
                              viewCount: w['view_count'] as int? ?? 0,
                              rating: (w['rating'] as num?)?.toDouble() ?? 0,
                              ratingCount: w['rating_count'] as int? ?? 0,
                              publishedAt: DateTime.tryParse(w['published_at'] as String? ?? '') ?? DateTime.now(),
                              updatedAt: DateTime.tryParse(w['updated_at'] as String? ?? '') ?? DateTime.now(),
                            ))
                        .toList() ?? [];

                    if (worksList.isEmpty) continue;

                    carousels.add(
                      _AuthorCarousel(
                        username: userJson['username'] as String? ?? 'Autor',
                        authorId: userJson['id'] as String? ?? '',
                        works: worksList,
                      ),
                    );
                  }
                  if (carousels.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                          child: Text('Autores Seguidos', style: KotobaTypography.headlineMd),
                        ),
                        ...carousels,
                        const Divider(color: AppColors.outlineVariant, height: 32, indent: 24, endIndent: 24),
                      ],
                    ),
                  );
                },
              ),

              // ── Sección: Obras Guardadas ────────────────
              if (works.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_border, size: 64, color: AppColors.onSurfaceVariant),
                        SizedBox(height: 16),
                        Text(
                          'No tienes obras guardadas',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Guarda obras para leerlas después',
                          style: TextStyle(color: AppColors.outlineVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                    child: Text('Guardados', style: KotobaTypography.headlineMd),
                  ),
                ),
              if (works.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final work = works[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: _LibraryWorkCard(work: work, onTap: () => context.go('/works/${work.id}')),
                      );
                    },
                    childCount: works.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}

class _AuthorCarousel extends ConsumerWidget {
  final String username;
  final String authorId;
  final List<Work> works;

  const _AuthorCarousel({
    required this.username,
    required this.authorId,
    required this.works,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/users/$authorId'),
                child: Row(
                  children: [
                    Text('@$username', style: KotobaTypography.labelMd),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final repo = ref.read(profileRepositoryProvider);
                  final result = await repo.unfollowUser(authorId);
                  result.fold(
                    (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
                    (_) {
                      ref.invalidate(followingAuthorsProvider);
                      ref.invalidate(publicAuthorProfileProvider(authorId));
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14, color: AppColors.onSurfaceVariant),
                      SizedBox(width: 4),
                      Text('Siguiendo', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24),
            itemCount: works.length,
            itemBuilder: (context, index) {
              final work = works[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: HorizontalWorkCarouselCard(
                  work: work,
                  onTap: () => context.go('/works/${work.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class HorizontalWorkCarouselCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const HorizontalWorkCarouselCard({required this.work, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: work.coverUrl != null
                  ? CachedNetworkImage(imageUrl: work.coverUrl!, fit: BoxFit.cover, width: double.infinity)
                  : Container(color: AppColors.surfaceHigh, child: const Center(child: Icon(Icons.book, color: AppColors.onSurfaceVariant))),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(work.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: KotobaTypography.labelMd),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 10, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text(work.rating.toStringAsFixed(1), style: KotobaTypography.labelXs),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryWorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const _LibraryWorkCard({required this.work, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: work.coverUrl != null
                  ? CachedNetworkImage(imageUrl: work.coverUrl!, fit: BoxFit.cover)
                  : Container(color: AppColors.surfaceHigh),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(work.title, style: KotobaTypography.headlineMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(work.synopsis, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.visibility, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(work.formattedViewCount, style: KotobaTypography.labelXs),
                        const SizedBox(width: 12),
                        const Icon(Icons.star, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(work.rating.toStringAsFixed(1), style: KotobaTypography.labelXs),
                        const SizedBox(width: 12),
                        const Icon(Icons.menu_book, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('${work.chapterCount}', style: KotobaTypography.labelXs),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
