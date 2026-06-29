import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/entities/work.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/i_content_repository.dart';

class WorkDetailState {
  final Work work;
  final List<Chapter> chapters;

  WorkDetailState({required this.work, required this.chapters});
}

class WorkDetailViewModel extends StateNotifier<AsyncValue<WorkDetailState>> {
  final IContentRepository _repository;
  final String _workId;

  WorkDetailViewModel(this._repository, this._workId)
      : super(const AsyncLoading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncLoading();
    final workResult = await _repository.getWorkDetail(_workId);
    final chaptersResult = await _repository.getChapters(_workId);

    workResult.fold(
      (f) => state = AsyncError(f.message, StackTrace.current),
      (work) => chaptersResult.fold(
        (f) => state = AsyncError(f.message, StackTrace.current),
        (chapters) {
          state = AsyncData(WorkDetailState(work: work, chapters: chapters));
          _repository.incrementView(_workId);
        },
      ),
    );
  }

  void updateVoteStats(double rating, int ratingCount) {
    state = state.whenData((current) => WorkDetailState(
      work: current.work.copyWith(rating: rating, ratingCount: ratingCount),
      chapters: current.chapters,
    ));
  }
}
