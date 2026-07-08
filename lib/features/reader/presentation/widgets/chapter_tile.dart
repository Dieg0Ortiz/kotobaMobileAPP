import 'package:flutter/material.dart';

import '../../../../core/theme/kotoba_colors.dart';
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
    final c = KotobaColors.of(context);
    return ListTile(
      onTap: chapter.isLocked ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        'Capítulo ${chapter.number}: ${chapter.title}',
        style: KotobaTypography.labelMd.copyWith(
          color: chapter.isLocked
              ? c.onSurfaceVariant.withValues(alpha: 0.5)
              : c.onSurface,
        ),
      ),
      subtitle: Text(
        '${chapter.readTimeMinutes} min lect. • ${chapter.publishedAt.day}/${chapter.publishedAt.month}/${chapter.publishedAt.year}',
        style: KotobaTypography.labelXs.copyWith(
          color: c.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      trailing: chapter.isLocked
          ? Icon(Icons.lock_outline,
              size: 20, color: c.onSurfaceVariant)
          : Icon(Icons.chevron_right,
              size: 24, color: c.onSurfaceVariant),
    );
  }
}
