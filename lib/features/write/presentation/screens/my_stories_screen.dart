import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../catalog/domain/entities/work.dart';

class MyStoriesScreen extends StatelessWidget {
  const MyStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Crear', style: KotobaTypography.headlineMd),
          actions: [
            TextButton(
              onPressed: () => context.go('/write/edit/new'),
              child: Text(
                'HISTORIA NUEVA',
                style: KotobaTypography.labelSm.copyWith(color: AppColors.action),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.action,
            labelColor: AppColors.action,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            tabs: [
              Tab(text: 'Publicado'),
              Tab(text: 'Borradores'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _StoriesList(works: MockData.myAuthoredWorks),
            _StoriesList(works: MockData.myDraftWorks),
          ],
        ),
      ),
    );
  }
}

class _StoriesList extends StatelessWidget {
  final List<Work> works;

  const _StoriesList({required this.works});

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return const Center(child: Text('No hay historias.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: works.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.outlineVariant, height: 32),
      itemBuilder: (context, index) {
        final work = works[index];
        return InkWell(
          onTap: () => context.go('/write/edit/${work.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 75,
                    height: 112,
                    child: work.coverUrl != null
                        ? CachedNetworkImage(
                            imageUrl: work.coverUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(color: AppColors.surfaceHigh),
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work.title,
                        style: KotobaTypography.headlineMd.copyWith(height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${work.chapterCount} parte publicada',
                              style: KotobaTypography.labelXs,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '0 borradores',
                            style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.visibility, size: 16, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(work.formattedViewCount, style: KotobaTypography.labelSm),
                          const SizedBox(width: 16),
                          const Icon(Icons.star_border, size: 16, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(work.rating.toStringAsFixed(1), style: KotobaTypography.labelSm),
                          const Spacer(),
                          const Icon(Icons.format_list_bulleted, size: 16, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 16),
                          const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.onSurfaceVariant),
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
    );
  }
}
