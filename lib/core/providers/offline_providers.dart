import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/download_service.dart';
import '../../features/catalog/domain/entities/work.dart';
import '../../features/reader/domain/entities/chapter.dart';

final isWorkDownloadedProvider = Provider.family<bool, String>((ref, workId) {
  return DownloadService.isWorkDownloaded(workId);
});

final downloadedWorkIdsProvider = Provider<List<String>>((ref) {
  return DownloadService.getDownloadedWorkIds();
});

final downloadedWorksProvider = Provider<List<Work>>((ref) {
  final ids = ref.watch(downloadedWorkIdsProvider);
  return ids.map((id) => DownloadService.loadWorkData(id)).whereType<Work>().toList();
});

final downloadedChaptersProvider = Provider.family<List<Chapter>, String>((ref, workId) {
  return DownloadService.loadChapters(workId);
});

final downloadProgressProvider = StateProvider<({String workId, int current, int total, String stage, String? error})?>((ref) => null);

final storageUsageProvider = FutureProvider<String>((ref) async {
  return DownloadService.getStorageUsage();
});
