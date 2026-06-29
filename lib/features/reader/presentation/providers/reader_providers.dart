import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/comment.dart';
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

final workCommentsProvider =
    FutureProvider.family<List<Comment>, String>((ref, workId) async {
  final repo = ref.read(contentRepositoryProvider);
  final result = await repo.getComments(workId);
  return result.fold((f) => throw f, (comments) => comments);
});

final myVoteProvider = FutureProvider.family<int, String>((ref, workId) async {
  final repo = ref.read(contentRepositoryProvider);
  final result = await repo.getMyVote(workId);
  return result.fold((f) => 0, (data) => data['user_vote'] as int? ?? 0);
});

final myBookmarkProvider = FutureProvider.family<bool, String>((ref, workId) async {
  final repo = ref.read(contentRepositoryProvider);
  final result = await repo.isBookmarked(workId);
  return result.fold((f) => false, (data) => data);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main');
});

final readerPreferencesProvider =
    NotifierProvider<ReaderPreferencesViewModel, ReaderPreferences>(
        ReaderPreferencesViewModel.new);
