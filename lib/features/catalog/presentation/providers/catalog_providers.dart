import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../catalog/data/repositories/mock_work_repository.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../catalog/domain/repositories/i_work_repository.dart';

// ── Repositorio ──────────────────────────────────────────────────
final workRepositoryProvider = Provider<IWorkRepository>((ref) {
  return MockWorkRepository();
});

// ── Datos del Home ───────────────────────────────────────────────
final trendingWorksProvider = FutureProvider<List<Work>>((ref) async {
  // 🔄 BACKEND INTEGRATION: usar repo real
  await Future.delayed(const Duration(milliseconds: 600));
  return MockData.trendingWorks;
});

final recommendedWorksProvider = FutureProvider<List<Work>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockData.trendingWorks.take(3).toList();
});

// ── Search ───────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedGenreProvider = StateProvider<String>((ref) => 'Todos');

final searchResultsProvider = FutureProvider<List<Work>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final genre = ref.watch(selectedGenreProvider);
  final repo = ref.read(workRepositoryProvider);
  final result = await repo.search(query, genre: genre);
  return result.fold((f) => throw f, (works) => works);
});
