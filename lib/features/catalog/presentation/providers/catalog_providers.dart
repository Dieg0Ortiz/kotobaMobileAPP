import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/data/repositories/work_repository_impl.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../catalog/domain/repositories/i_work_repository.dart';

final workRepositoryProvider = Provider<IWorkRepository>((ref) {
  final api = ref.read(contentApiClientProvider);
  return WorkRepositoryImpl(api);
});

final trendingWorksProvider = FutureProvider<List<Work>>((ref) async {
  final repo = ref.read(workRepositoryProvider);
  final result = await repo.getTrending();
  return result.fold((f) => throw f, (works) => works);
});

final recommendedWorksProvider = FutureProvider<List<Work>>((ref) async {
  final repo = ref.read(workRepositoryProvider);
  final result = await repo.getRecommended();
  return result.fold((f) => throw f, (works) => works.take(3).toList());
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedGenreProvider = StateProvider<String>((ref) => 'Todos');

final searchResultsProvider = FutureProvider<List<Work>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final genre = ref.watch(selectedGenreProvider);
  final repo = ref.read(workRepositoryProvider);
  final result = await repo.search(query, genre: genre);
  return result.fold((f) => throw f, (works) => works);
});
