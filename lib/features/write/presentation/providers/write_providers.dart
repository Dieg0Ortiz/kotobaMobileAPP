import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/entities/work.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../reader/presentation/providers/reader_providers.dart';

class WriteDashboardData {
  final Work latestWork;
  final int publishedParts;
  final int drafts;

  WriteDashboardData({
    required this.latestWork,
    required this.publishedParts,
    required this.drafts,
  });
}

final writeDashboardProvider = FutureProvider<WriteDashboardData?>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final workRepo = ref.watch(workRepositoryProvider);
  final contentRepo = ref.watch(contentRepositoryProvider);

  final worksResult = await workRepo.getWorksByAuthor(user.id);
  final works = worksResult.fold((f) => throw f, (works) => works);

  if (works.isEmpty) {
    return null;
  }

  // Ordenar por actualización descendente para encontrar la más reciente
  works.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  final latestWork = works.first;

  final chaptersResult = await contentRepo.getChapters(latestWork.id);
  final chapters = chaptersResult.fold((f) => throw f, (chapters) => chapters);

  int publishedCount = 0;
  int draftCount = 0;

  for (final chapter in chapters) {
    if (chapter.status == 'published') {
      publishedCount++;
    } else {
      draftCount++; // Cualquier otro estado se asume como borrador
    }
  }

  return WriteDashboardData(
    latestWork: latestWork,
    publishedParts: publishedCount,
    drafts: draftCount,
  );
});
