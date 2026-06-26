import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_avatar.dart';
import '../../../../core/widgets/common/kotoba_button.dart';
import '../../../auth/domain/entities/user.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Container(color: AppColors.surfaceHigh),
          ),
        
        // Dark gradient overlay for readability (darker at bottom)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.5),
                  AppColors.background.withValues(alpha: 0.95),
                  AppColors.background,
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
                  user.username,
                  style: KotobaTypography.headlineLg.copyWith(
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.email.split('@').first}', // Pseudo handle
                  style: KotobaTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('${user.worksCount}', 'OBRAS'),
                    _buildStat('2', 'LISTAS'), // Fixed for UI demonstration
                    _buildStat('${user.followers}', 'SEGUIDORES'),
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: KotobaTypography.headlineMd),
        const SizedBox(height: 4),
        Text(label, style: KotobaTypography.labelXs.copyWith(letterSpacing: 1.0)),
      ],
    );
  }
}
