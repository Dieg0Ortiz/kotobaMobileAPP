import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_button.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

final myWorksProvider = FutureProvider.family<List<Work>, String>((ref, authorId) async {
  final repo = ref.read(workRepositoryProvider);
  final result = await repo.getWorksByAuthor(authorId);
  return result.fold((f) => throw f, (works) => works);
});

class MyStoriesScreen extends ConsumerWidget {
  const MyStoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user.id.isEmpty) {
          return const Scaffold(body: Center(child: Text('Debes iniciar sesión')));
        }
        return _MyStoriesBody(authorId: user.id);
      },
    );
  }
}

class _MyStoriesBody extends ConsumerWidget {
  final String authorId;

  const _MyStoriesBody({required this.authorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(myWorksProvider(authorId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Mis Historias', style: KotobaTypography.headlineMd),
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
        body: worksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (works) {
            final published = works.where((w) => w.status == 'published' || w.status == 'ongoing' || w.status == 'completed').toList();
            final drafts = works.where((w) => w.status == 'draft').toList();

            return TabBarView(
              children: [
                _WorksList(works: published, emptyMsg: 'No hay historias publicadas.'),
                _WorksList(works: drafts, emptyMsg: 'No hay borradores.'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WorksList extends StatelessWidget {
  final List<Work> works;
  final String emptyMsg;

  const _WorksList({required this.works, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emptyMsg, style: KotobaTypography.bodyMd, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              KotobaButton(
                label: 'Crear historia',
                fullWidth: false,
                onPressed: () => context.go('/write/edit/new'),
              ),
            ],
          ),
        ),
      );
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 75,
                    height: 112,
                    child: work.coverUrl != null
                        ? CachedNetworkImage(imageUrl: work.coverUrl!, fit: BoxFit.cover)
                        : Container(color: AppColors.surfaceHigh),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(work.title, style: KotobaTypography.headlineMd.copyWith(height: 1.2),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('${work.chapterCount} parte publicada',
                                style: KotobaTypography.labelXs),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 32,
                            child: KotobaButton(
                              label: 'Escribir capítulo',
                              fullWidth: false,
                              onPressed: () => context.go('/write/edit/${work.id}/chapter/new'),
                            ),
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
    );
  }
}
