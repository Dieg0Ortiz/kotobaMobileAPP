import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../providers/reader_providers.dart';
import '../widgets/font_settings_sheet.dart';

/// Lector de capítulos inmersivo.
class ChapterReaderScreen extends ConsumerStatefulWidget {
  final String chapterId;

  const ChapterReaderScreen({required this.chapterId, super.key});

  @override
  ConsumerState<ChapterReaderScreen> createState() =>
      _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  bool _showOverlay = true;

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  void _showFontSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const FontSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterContentProvider(widget.chapterId));
    final prefs = ref.watch(readerPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: chapterAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (chapter) => GestureDetector(
          onTap: _toggleOverlay,
          child: Stack(
            children: [
              // Contenido
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
                children: [
                  Text(
                    chapter.title,
                    style: TextStyle(
                      fontFamily: 'Noto Serif JP',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    chapter.content,
                    style: TextStyle(
                      fontFamily: prefs.fontFamily,
                      fontSize: prefs.fontSize,
                      height: 1.8,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              // Top Bar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                top: _showOverlay ? 0 : -80,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 32),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.9),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.text_format),
                        onPressed: _showFontSettings,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
