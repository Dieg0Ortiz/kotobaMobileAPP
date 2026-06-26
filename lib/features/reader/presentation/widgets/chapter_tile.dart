import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../domain/entities/chapter.dart';

/// Ítem de la lista de capítulos con 3 estados: leído, activo, bloqueado.
class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const ChapterTile({
    required this.chapter,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: chapter.isLocked ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        'Capítulo ${chapter.number}: ${chapter.title}',
        style: KotobaTypography.labelMd.copyWith(
          color: chapter.isLocked
              ? AppColors.onSurfaceVariant.withValues(alpha: 0.5)
              : AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        '${chapter.readTimeMinutes} min lect. • ${chapter.publishedAt.day}/${chapter.publishedAt.month}/${chapter.publishedAt.year}',
        style: KotobaTypography.labelXs.copyWith(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      trailing: chapter.isLocked
          ? const Icon(Icons.lock_outline,
              size: 20, color: AppColors.onSurfaceVariant)
          : const Icon(Icons.chevron_right,
              size: 24, color: AppColors.onSurfaceVariant),
    );
  }
}
