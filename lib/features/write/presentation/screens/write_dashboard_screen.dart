import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../../core/widgets/common/kotoba_avatar.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/write_providers.dart';

class WriteDashboardScreen extends ConsumerWidget {
  const WriteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final dashboardDataAsync = ref.watch(writeDashboardProvider);
    final c = KotobaColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Escribir', style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
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
          dashboardDataAsync.when(
            data: (data) {
              if (data == null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: c.surfaceLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.edit_note, size: 48, color: c.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text('Comienza tu viaje', style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
                      const SizedBox(height: 8),
                      Text(
                        'Aún no has escrito ninguna historia. ¡Crea una ahora!',
                        textAlign: TextAlign.center,
                        style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              }

              final lastWork = data.latestWork;
              return GestureDetector(
                onTap: () => context.push('/write/edit/${lastWork.id}'),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surfaceLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
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
                              : Container(color: c.surfaceHigh),
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
                              style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastWork.title,
                              style: KotobaTypography.headlineMd.copyWith(height: 1.2, color: c.onSurface),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: c.surfaceHigh,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${data.publishedParts} parte${data.publishedParts == 1 ? '' : 's'} publicada${data.publishedParts == 1 ? '' : 's'}',
                                    style: KotobaTypography.labelXs.copyWith(color: c.onSurface),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${data.drafts} borrador${data.drafts == 1 ? '' : 'es'}',
                                  style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => Container(
              height: 137,
              decoration: BoxDecoration(
                color: c.surfaceLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: const Center(child: KotobaLoading()),
            ),
            error: (e, st) => Container(
              height: 137,
              decoration: BoxDecoration(
                color: c.surfaceLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.error.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Text('Error al cargar historias', style: KotobaTypography.labelSm.copyWith(color: c.error)),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Menu Options
          _buildMenuOption(
            icon: Icons.menu_book,
            title: 'Historias',
            onTap: () => context.push('/write/stories'),
            context: context,
          ),
          _buildMenuOption(
            icon: Icons.collections_bookmark,
            title: 'Series',
            onTap: () {},
            context: context,
          ),
          _buildMenuOption(
            icon: Icons.add_box_outlined,
            title: 'Crea una historia nueva',
            onTap: () => context.push('/write/edit/new'),
            context: context,
          ),

        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final c = KotobaColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: c.onSurfaceVariant, size: 24),
            const SizedBox(width: 20),
            Text(
              title,
              style: KotobaTypography.bodyLg.copyWith(color: c.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
