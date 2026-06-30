import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../domain/entities/work.dart';

/// Card de obra para el catálogo: portada, badge de género, título, autor, stats.
class WorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const WorkCard({required this.work, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    work.coverUrl != null
                        ? CachedNetworkImage(
                            imageUrl: work.coverUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.surfaceLow,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceLow,
                              child: const Icon(
                                Icons.menu_book,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceLow,
                            child: const Icon(
                              Icons.menu_book,
                              color: AppColors.onSurfaceVariant,
                              size: 32,
                            ),
                          ),
                    // Badge de género
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          work.genre.toUpperCase(),
                          style: KotobaTypography.genreLabel,
                        ),
                      ),
                    ),
                    // Rating badge
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.thumb_up_rounded,
                                size: 12, color: AppColors.primary),
                            const SizedBox(width: 3),
                            Text(
                              work.ratingCount.toString(),
                              style: KotobaTypography.labelXs
                                  .copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Título
            Text(
              work.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: KotobaTypography.labelMd,
            ),
            const SizedBox(height: 2),
            // Autor
            Text(
              work.authorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KotobaTypography.labelXs,
            ),
          ],
        ),
      ),
    );
  }
}
