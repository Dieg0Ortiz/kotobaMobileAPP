import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_button.dart';
import '../../domain/entities/work.dart';

/// Card grande de recomendación principal: "Selección Para Ti".
class FeaturedCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const FeaturedCard({required this.work, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: c.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: c.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    work.coverUrl != null
                        ? CachedNetworkImage(
                            imageUrl: work.coverUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(color: c.surface),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            c.surfaceLow.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                    // Badge "Recomendación Principal"
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: c.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          AppStrings.mainRecommendation,
                          style: KotobaTypography.genreLabel.copyWith(
                            color: c.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Text content
            Padding(
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
                  const SizedBox(height: 4),
                  Text(
                    '${work.authorName} · ${work.genre} · ${work.chapterCount} caps',
                    style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    work.synopsis,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: KotobaTypography.bodyMd.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  KotobaButton(
                    label: AppStrings.startReading,
                    onPressed: onTap,
                    fullWidth: false,
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
