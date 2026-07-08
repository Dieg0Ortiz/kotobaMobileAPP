import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../catalog/domain/entities/work.dart';

class DetailedWorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const DetailedWorkCard({required this.work, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: c.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.onSurface.withValues(alpha: 0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Badge
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (work.coverUrl != null)
                    CachedNetworkImage(
                      imageUrl: work.coverUrl!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )
                  else
                    Container(color: c.surfaceHigh),
                  
                  // Gradient for badge readability
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: c.background.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            work.status == 'completed' ? Icons.library_add_check : Icons.edit_note,
                            size: 14,
                            color: c.onSurface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            work.status == 'completed' ? 'Completada' : 'En Progreso',
                            style: KotobaTypography.labelXs.copyWith(color: c.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(work.title, style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
                  const SizedBox(height: 6),
                  Text(
                    '${work.genre} • ${(work.wordCount / 1000).toStringAsFixed(0)}k palabras',
                    style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    work.synopsis,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: c.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(work.formattedViewCount, style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant)),
                      const SizedBox(width: 20),
                      Icon(Icons.star, size: 16, color: c.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(work.rating.toStringAsFixed(1), style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant)),
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
