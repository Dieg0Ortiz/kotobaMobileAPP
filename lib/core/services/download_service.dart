import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../../features/catalog/domain/entities/work.dart';
import '../../features/reader/domain/entities/chapter.dart';

class DownloadProgress {
  final int current;
  final int total;
  final String stage; // 'downloading', 'saving', 'done', 'error'
  final String? error;

  const DownloadProgress({
    required this.current,
    required this.total,
    this.stage = 'downloading',
    this.error,
  });

  double get fraction => total > 0 ? current / total : 0;
}

class DownloadService {
  static const _boxName = 'offline';
  static const _worksKey = 'downloadedWorks';
  static const _chaptersPrefix = 'chapters_';

  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // ── Work manifest ───────────────────────────────────────────

  static List<String> getDownloadedWorkIds() {
    final data = _box.get(_worksKey, defaultValue: <dynamic>[]) as List;
    return data.cast<String>();
  }

  static bool isWorkDownloaded(String workId) {
    return getDownloadedWorkIds().contains(workId);
  }

  static Future<void> _addWorkToManifest(String workId) async {
    final ids = getDownloadedWorkIds();
    if (!ids.contains(workId)) {
      ids.add(workId);
      await _box.put(_worksKey, ids);
    }
  }

  static Future<void> _removeWorkFromManifest(String workId) async {
    final ids = getDownloadedWorkIds();
    ids.remove(workId);
    await _box.put(_worksKey, ids);
  }

  // ── Work data ────────────────────────────────────────────────

  static Future<void> saveWorkData(Work work) async {
    final json = work.toJson();
    await _box.put('work_${work.id}', jsonEncode(json));
  }

  static Work? loadWorkData(String workId) {
    final raw = _box.get('work_$workId');
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      return Work.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ── Chapters ─────────────────────────────────────────────────

  static Future<void> saveChapter(String workId, Chapter chapter) async {
    final key = '$_chaptersPrefix$workId';
    final data = _box.get(key, defaultValue: <dynamic>[]) as List;
    final existingIndex = data.indexWhere((e) {
      try {
        final m = jsonDecode(e as String) as Map<String, dynamic>;
        return m['id'] == chapter.id;
      } catch (_) {
        return false;
      }
    });
    final encoded = jsonEncode(chapter.toJson());
    if (existingIndex >= 0) {
      data[existingIndex] = encoded;
    } else {
      data.add(encoded);
    }
    await _box.put(key, data);
  }

  static List<Chapter> loadChapters(String workId) {
    final key = '$_chaptersPrefix$workId';
    final data = _box.get(key, defaultValue: <dynamic>[]) as List;
    return data.map((e) {
      try {
        final json = jsonDecode(e as String) as Map<String, dynamic>;
        return Chapter.fromJson(json);
      } catch (_) {
        return null;
      }
    }).whereType<Chapter>().toList();
  }

  static int downloadedChapterCount(String workId) {
    return loadChapters(workId).length;
  }

  // ── Download work (with all chapters) ─────────────────────────

  static Future<void> downloadWork({
    required Work work,
    required List<Chapter> chapters,
    required void Function(DownloadProgress) onProgress,
  }) async {
    try {
      onProgress(DownloadProgress(current: 0, total: chapters.length + 1, stage: 'saving'));

      await saveWorkData(work);
      onProgress(DownloadProgress(current: 1, total: chapters.length + 1, stage: 'saving'));

      for (int i = 0; i < chapters.length; i++) {
        await saveChapter(work.id, chapters[i]);
        onProgress(DownloadProgress(current: i + 2, total: chapters.length + 1, stage: 'downloading'));
      }

      await _addWorkToManifest(work.id);
      onProgress(DownloadProgress(current: chapters.length + 1, total: chapters.length + 1, stage: 'done'));
    } catch (e) {
      onProgress(DownloadProgress(current: 0, total: 0, stage: 'error', error: e.toString()));
    }
  }

  // ── Download single chapter ───────────────────────────────────

  static Future<void> downloadChapter({
    required Work work,
    required Chapter chapter,
    required void Function(DownloadProgress) onProgress,
  }) async {
    try {
      onProgress(const DownloadProgress(current: 0, total: 2, stage: 'saving'));

      if (!isWorkDownloaded(work.id)) {
        await saveWorkData(work);
      }
      onProgress(const DownloadProgress(current: 1, total: 2, stage: 'saving'));

      await saveChapter(work.id, chapter);
      onProgress(const DownloadProgress(current: 2, total: 2, stage: 'done'));

      if (!isWorkDownloaded(work.id)) {
        await _addWorkToManifest(work.id);
      }
    } catch (e) {
      onProgress(DownloadProgress(current: 0, total: 0, stage: 'error', error: e.toString()));
    }
  }

  // ── Delete ──────────────────────────────────────────────────

  static Future<void> deleteWork(String workId) async {
    await _box.delete('work_$workId');
    await _box.delete('$_chaptersPrefix$workId');
    await _removeWorkFromManifest(workId);
  }

  static Future<void> deleteChapter(String workId, String chapterId) async {
    final key = '$_chaptersPrefix$workId';
    final data = _box.get(key, defaultValue: <dynamic>[]) as List;
    data.removeWhere((e) {
      try {
        final m = jsonDecode(e as String) as Map<String, dynamic>;
        return m['id'] == chapterId;
      } catch (_) {
        return false;
      }
    });
    await _box.put(key, data);
  }

  // ── Storage info ─────────────────────────────────────────────

  static Future<String> getStorageUsage() async {
    final dir = await getApplicationDocumentsDirectory();
    final boxPath = '${dir.path}/${AppConstants.appName}/hive';
    final boxDir = Directory(boxPath);
    if (!await boxDir.exists()) return '0 MB';
    int totalSize = 0;
    await for (final file in boxDir.list(recursive: true)) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
