import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../profile/presentation/widgets/horizontal_work_card.dart';
import '../../../reader/presentation/providers/reader_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(myBookmarksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Biblioteca', style: KotobaTypography.headlineMd),
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (works) {
          if (works.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: AppColors.onSurfaceVariant),
                  SizedBox(height: 16),
                  Text(
                    'No tienes obras guardadas',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Guarda obras para leerlas después',
                    style: TextStyle(color: AppColors.outlineVariant, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: works.length,
            itemBuilder: (context, index) {
              final work = works[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HorizontalWorkCard(
                  work: work,
                  onTap: () => context.go('/works/${work.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
