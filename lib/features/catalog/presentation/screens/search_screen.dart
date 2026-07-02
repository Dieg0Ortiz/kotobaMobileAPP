import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../providers/catalog_providers.dart';
import '../widgets/genre_filter_row.dart';
import '../widgets/work_card.dart';

/// Pantalla de búsqueda con filtros y grid de resultados.
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: TextField(
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.onSurfaceVariant, size: 20),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.onSurfaceVariant, size: 18),
                          onPressed: () => ref
                              .read(searchQueryProvider.notifier)
                              .state = '',
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Genre filter chips
            GenreFilterRow(
              selectedGenre: selectedGenre,
              onGenreSelected: (genre) =>
                  ref.read(selectedGenreProvider.notifier).state = genre,
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: resultsAsync.when(
                loading: () => const Center(child: KotobaLoading()),
                error: (e, _) => Center(
                  child: Text(e.toString(),
                      style: KotobaTypography.labelMd
                          .copyWith(color: AppColors.error)),
                ),
                data: (works) {
                  if (works.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off,
                              size: 48, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(AppStrings.noResults,
                              style: KotobaTypography.labelMd
                                  .copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.42,
                    ),
                    itemCount: works.length,
                    itemBuilder: (_, i) => WorkCard(
                      work: works[i],
                      onTap: () => context.push('/works/${works[i].id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
