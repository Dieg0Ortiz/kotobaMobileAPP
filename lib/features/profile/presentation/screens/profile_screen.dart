import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../providers/profile_providers.dart';
import '../widgets/horizontal_work_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_sidebar_widgets.dart';
import '../widgets/settings_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) => CustomScrollView(
          slivers: [
            // 1. Cabecera Extendida
            SliverAppBar(
              expandedHeight: 480, 
              pinned: true,
              title: Text(user.username),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _showSettings(context),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: ProfileHeader(user: user),
              ),
            ),

            // 2. Sección: Acerca De (Bio)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACERCA DE',
                      style: KotobaTypography.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.bio ?? 'Sin biografía.',
                      style: KotobaTypography.bodyMd,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(user.country ?? '', style: KotobaTypography.labelSm),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Se unió el ${_formatDate(user.createdAt)}', 
                      style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.outlineVariant),
                  ],
                ),
              ),
            ),

            // 3. Sección: Historias (Carrusel Horizontal)
            SliverToBoxAdapter(
              child: _UserWorksCarousel(userId: user.id, username: user.username, worksCount: user.worksCount),
            ),

            // 4. Sección: Siguiendo / Autores Similares
            const SliverToBoxAdapter(
              child: SimilarAuthorsCard(),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Divider(color: AppColors.outlineVariant),
              ),
            ),

            // 5. Sección: Logros y Géneros
            const SliverToBoxAdapter(
              child: AchievementsCard(),
            ),
            const SliverToBoxAdapter(
              child: GenresCard(),
            ),

            // 6. Sección: Actividad
            const SliverToBoxAdapter(
              child: ActivityTimeline(),
            ),

            // 7. Pull Quote al final
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Text(
                  '"La tinta es la sangre de mundos que aún no existen."',
                  textAlign: TextAlign.center,
                  style: KotobaTypography.pullQuote,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carrusel de obras del usuario conectado al backend real.
class _UserWorksCarousel extends ConsumerWidget {
  final String userId;
  final String username;
  final int worksCount;

  const _UserWorksCarousel({
    required this.userId,
    required this.username,
    required this.worksCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(userWorksProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Historias de @${username}',
                  style: KotobaTypography.headlineMd,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 4, bottom: 16),
          child: Text(
            '$worksCount Historias publicadas',
            style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        worksAsync.when(
          loading: () => const SizedBox(
            height: 220,
            child: Center(child: KotobaLoading()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (works) {
            if (works.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text('Aún no has publicado historias'),
                ),
              );
            }
            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24),
                itemCount: works.length,
                itemBuilder: (context, index) {
                  return HorizontalWorkCard(work: works[index]);
                },
              ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Divider(color: AppColors.outlineVariant),
        ),
      ],
    );
  }
}
