import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../catalog/domain/entities/work.dart';

class HorizontalWorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const HorizontalWorkCard({required this.work, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, // Takes up most of the screen width
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: c.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.onSurface.withValues(alpha: 0.05)),
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
                  : Container(color: c.surfaceHigh),
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
                      style: KotobaTypography.headlineMd.copyWith(color: c.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Icon(Icons.visibility, size: 14, color: c.onSurfaceVariant),
                        Text(work.formattedViewCount, style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant)),
                        const SizedBox(width: 4),
                        Icon(Icons.thumb_up_rounded, size: 14, color: c.onSurfaceVariant),
                        Text('${work.ratingCount}', style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant)),
                        const SizedBox(width: 4),
                        Icon(Icons.menu_book, size: 14, color: c.onSurfaceVariant),
                        Text('${work.chapterCount}', style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        work.synopsis,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          work.status == 'completed' ? Icons.library_add_check : Icons.edit_note,
                          size: 14,
                          color: c.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          work.status == 'completed' ? 'Completada' : 'En Progreso',
                          style: KotobaTypography.labelXs.copyWith(color: c.primary),
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
