import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../catalog/domain/entities/work.dart';

class HorizontalWorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const HorizontalWorkCard({required this.work, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, // Takes up most of the screen width
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            AspectRatio(
              aspectRatio: 2 / 3,
              child: work.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: work.coverUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: AppColors.surfaceHigh),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      work.title,
                      style: KotobaTypography.headlineMd,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Icon(Icons.visibility, size: 14, color: AppColors.onSurfaceVariant),
                        Text(work.formattedViewCount, style: KotobaTypography.labelXs),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 14, color: AppColors.onSurfaceVariant),
                        Text(work.rating.toStringAsFixed(1), style: KotobaTypography.labelXs),
                        const SizedBox(width: 4),
                        const Icon(Icons.menu_book, size: 14, color: AppColors.onSurfaceVariant),
                        Text('${work.chapterCount}', style: KotobaTypography.labelXs),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        work.synopsis,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          work.status == 'completed' ? Icons.library_add_check : Icons.edit_note,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          work.status == 'completed' ? 'Completada' : 'En Progreso',
                          style: KotobaTypography.labelXs.copyWith(color: AppColors.primary),
                        ),
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
