import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/i_content_repository.dart';
import '../viewmodels/reader_viewmodel.dart';
import '../viewmodels/work_detail_viewmodel.dart';

final contentRepositoryProvider = Provider<IContentRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return ContentRepositoryImpl(api);
});

final workDetailViewModelProvider = StateNotifierProvider.family<
    WorkDetailViewModel, AsyncValue<WorkDetailState>, String>((ref, workId) {
  return WorkDetailViewModel(ref.read(contentRepositoryProvider), workId);
});

final chapterContentProvider =
    FutureProvider.family<Chapter, String>((ref, chapterId) async {
  final repo = ref.read(contentRepositoryProvider);
  final result = await repo.getChapter(chapterId);
  return result.fold((f) => throw f, (chapter) => chapter);
});

final readerPreferencesProvider =
    NotifierProvider<ReaderPreferencesViewModel, ReaderPreferences>(
        ReaderPreferencesViewModel.new);
