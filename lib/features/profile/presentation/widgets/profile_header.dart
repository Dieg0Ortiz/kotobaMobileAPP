import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_avatar.dart';
import '../../../../core/widgets/common/kotoba_button.dart';
import '../../../auth/domain/entities/user.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback? onSettingsTap;

  const ProfileHeader({required this.user, this.onSettingsTap, super.key});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return Stack(
      children: [
        // Banner Image
        if (user.bannerUrl != null)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: user.bannerUrl!,
              fit: BoxFit.cover,
            ),
          )
        else
          Positioned.fill(
            child: Container(color: c.surfaceHigh),
          ),
        
        // Gradient overlay for readability (darker at bottom)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  c.background.withValues(alpha: 0.5),
                  c.background.withValues(alpha: 0.95),
                  c.background,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // Centered
              children: [
                KotobaAvatar(
                  imageUrl: user.avatarUrl,
                  size: KotobaAvatarSize.xl, // Bigger avatar
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName?.isNotEmpty == true ? user.fullName! : user.username,
                  style: KotobaTypography.headlineLg.copyWith(
                    color: c.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: KotobaTypography.labelMd.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat(context, '${user.worksCount}', 'OBRAS'),
                    _buildStat(context, '0', 'LISTAS'),
                    _buildStat(context, '${user.followers}', 'SEGUIDORES'),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: KotobaButton(
                        label: 'Seguir',
                        icon: Icons.person_add_alt_1,
                        variant: KotobaButtonVariant.action,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KotobaButton(
                        label: 'Apoyar',
                        icon: Icons.favorite_border,
                        variant: KotobaButtonVariant.ghost,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Acerca De (Bio)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACERCA DE',
                        style: KotobaTypography.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: c.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.bio ?? 'Sin biografía.',
                        style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: c.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(user.country ?? '', style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Se unió el ${_formatDate(user.createdAt)}', 
                        style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Settings Button at the top right
        if (onSettingsTap != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.settings_outlined, color: c.onSurface),
              onPressed: onSettingsTap,
            ),
          ),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    final c = KotobaColors.of(context);
    return Column(
      children: [
        Text(value, style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
        const SizedBox(height: 4),
        Text(label, style: KotobaTypography.labelXs.copyWith(letterSpacing: 1.0, color: c.onSurfaceVariant)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
