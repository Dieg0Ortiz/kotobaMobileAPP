import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_avatar.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class WriteDashboardScreen extends ConsumerWidget {
  const WriteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final lastWork = MockData.myAuthoredWorks.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escribir', style: KotobaTypography.headlineMd),
        actions: [
          profileAsync.maybeWhen(
            data: (user) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: KotobaAvatar(imageUrl: user.avatarUrl, size: KotobaAvatarSize.sm),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Last Work Card
          GestureDetector(
            onTap: () => context.go('/write/edit/${lastWork.id}'),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 70,
                      height: 105,
                      child: lastWork.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl: lastWork.coverUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: AppColors.surfaceHigh),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seguir escribiendo',
                          style: KotobaTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastWork.title,
                          style: KotobaTypography.headlineMd.copyWith(height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${lastWork.chapterCount} parte publicada',
                                style: KotobaTypography.labelXs,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '0 borrador',
                              style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Menu Options
          _buildMenuOption(
            icon: Icons.menu_book,
            title: 'Historias',
            onTap: () => context.go('/write/stories'),
          ),
          _buildMenuOption(
            icon: Icons.collections_bookmark,
            title: 'Series',
            onTap: () {},
          ),
          _buildMenuOption(
            icon: Icons.add_box_outlined,
            title: 'Crea una historia nueva',
            onTap: () => context.go('/write/edit/new'),
          ),

        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
            const SizedBox(width: 20),
            Text(
              title,
              style: KotobaTypography.bodyLg,
            ),
          ],
        ),
      ),
    );
  }
}
