import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/kotoba_colors.dart';

/// Avatar circular con borde gold y 4 tamaños.
enum KotobaAvatarSize { sm, md, lg, xl }

class KotobaAvatar extends StatelessWidget {
  final String? imageUrl;
  final KotobaAvatarSize size;
  final bool showBorder;

  const KotobaAvatar({
    this.imageUrl,
    this.size = KotobaAvatarSize.md,
    this.showBorder = true,
    super.key,
  });

  double get _size {
    switch (size) {
      case KotobaAvatarSize.sm:
        return 32;
      case KotobaAvatarSize.md:
        return 48;
      case KotobaAvatarSize.lg:
        return 72;
      case KotobaAvatarSize.xl:
        return 96;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: c.primaryContainer, width: 2)
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: c.surfaceHigh,
                  child: Icon(
                    Icons.person,
                    size: _size * 0.5,
                    color: c.onSurfaceVariant,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: c.surfaceHigh,
                  child: Icon(
                    Icons.person,
                    size: _size * 0.5,
                    color: c.onSurfaceVariant,
                  ),
                ),
              )
            : Container(
                color: c.surfaceHigh,
                child: Icon(
                  Icons.person,
                  size: _size * 0.5,
                  color: c.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}
