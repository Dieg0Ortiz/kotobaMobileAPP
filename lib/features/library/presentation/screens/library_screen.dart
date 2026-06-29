import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../reader/presentation/providers/reader_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(myBookmarksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Biblioteca', style: KotobaTypography.headlineMd),
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (works) {
          if (works.isEmpty) {
            return const Center(
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
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: works.length,
            itemBuilder: (context, index) {
              final work = works[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LibraryWorkCard(work: work, onTap: () => context.go('/works/${work.id}')),
              );
            },
          );
        },
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
