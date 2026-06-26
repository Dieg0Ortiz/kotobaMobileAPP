import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_button.dart';
import '../../../../core/widgets/common/kotoba_chip.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../providers/reader_providers.dart';
import '../widgets/chapter_tile.dart';
import '../widgets/synopsis_card.dart';

/// Pantalla de detalle de la obra.
class WorkDetailScreen extends ConsumerWidget {
  final String workId;

  const WorkDetailScreen({required this.workId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(workDetailViewModelProvider(workId));

    return Scaffold(
      body: stateAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (state) {
          final work = state.work;
          final chapters = state.chapters;

          return CustomScrollView(
            slivers: [
              // Hero cover
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (work.coverUrl != null)
                        CachedNetworkImage(
                          imageUrl: work.coverUrl!,
                          fit: BoxFit.cover,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.8),
                              AppColors.background,
                            ],
                            stops: const [0.4, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Meta info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work.title,
                        style: KotobaTypography.displayXL,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Por ${work.authorName}',
                        style: KotobaTypography.headlineMd.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          KotobaChip(label: work.genre),
                          KotobaChip(label: work.status),
                          KotobaChip(
                              label: '${work.formattedViewCount} lecturas'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: KotobaButton(
                              label: AppStrings.startReading,
                              onPressed: () {
                                if (chapters.isNotEmpty) {
                                  context.go(
                                      '/works/$workId/chapters/${chapters.first.id}');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: KotobaButton(
                              label: AppStrings.supportAuthor,
                              variant: KotobaButtonVariant.ghost,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        AppStrings.synopsis,
                        style: KotobaTypography.headlineMd,
                      ),
                      const SizedBox(height: 16),
                      SynopsisCard(text: work.synopsis),
                      const SizedBox(height: 32),
                      Text(
                        AppStrings.chapterIndex,
                        style: KotobaTypography.headlineMd,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Chapter list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = chapters[index];
                    return ChapterTile(
                      chapter: chapter,
                      onTap: () => context
                          .go('/works/$workId/chapters/${chapter.id}'),
                    );
                  },
                  childCount: chapters.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}
