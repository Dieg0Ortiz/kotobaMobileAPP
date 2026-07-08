import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../domain/entities/work.dart';

/// Card de obra para el catálogo: portada, badge de género, título, autor, stats.
class WorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const WorkCard({required this.work, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
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
                              color: c.surfaceLow,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: c.surfaceLow,
                              child: Icon(
                                Icons.menu_book,
                                color: c.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Container(
                            color: c.surfaceLow,
                            child: Icon(
                              Icons.menu_book,
                              color: c.onSurfaceVariant,
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
                          color: c.background.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          work.genre.toUpperCase(),
                          style: KotobaTypography.genreLabel.copyWith(color: c.onSurface),
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
                          color: c.background.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.thumb_up_rounded,
                                size: 12, color: c.primary),
                            const SizedBox(width: 3),
                            Text(
                              work.ratingCount.toString(),
                              style: KotobaTypography.labelXs
                                  .copyWith(color: c.primary),
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
              style: KotobaTypography.labelMd.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: 2),
            // Autor
            Text(
              work.authorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
