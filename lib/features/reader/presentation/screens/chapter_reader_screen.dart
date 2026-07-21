import 'dart:convert';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../providers/reader_providers.dart';
import '../viewmodels/reader_viewmodel.dart';
import '../widgets/font_settings_sheet.dart';

class ChapterReaderScreen extends ConsumerStatefulWidget {
  final String chapterId;
  final String? workId; // needed for reading progress

  const ChapterReaderScreen({required this.chapterId, this.workId, super.key});

  @override
  ConsumerState<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ParagraphBlock {
  final TextSpan span;
  final String plainText;
  final bool isBlockquote;
  final bool isEmpty;

  _ParagraphBlock({
    required this.span,
    required this.plainText,
    this.isBlockquote = false,
    this.isEmpty = false,
  });
}

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  bool _showOverlay = true;
  bool _viewCounted = false;
  bool _progressLoaded = false;
  bool _isNavigatingToNext = false;
  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  int _currentPage = 0;

  // ── Page-mode state ──
  String _lastPageKey = '';
  List<List<Widget>> _pageGroups = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
  }

  void _showFontSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const FontSettingsSheet(),
    );
  }

  // ── Delta parsing ─────────────────────────────────────────────────

  Delta _parseDelta(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return Delta.fromJson(decoded);
      }
      return Delta()..insert(content);
    } catch (_) {
      return Delta()..insert(content);
    }
  }

  // ── Build rich text widgets from Quill Delta (for Cascade mode) ──

  List<Widget> _buildChapterWidgetsDelta(
    Delta delta,
    double fontSize,
    String fontFamily,
    KotobaColors c,
  ) {
    final doc = quill.Document.fromDelta(delta);
    List<Widget> children = [];
    bool isFirstBlock = true;

    for (var node in doc.root.children) {
      if (node is quill.Line) {
        List<TextSpan> spans = [];
        bool isBlockquote = node.style.attributes.containsKey('blockquote');

        for (var leaf in node.children) {
          final text = leaf.toPlainText();
          if (text.trim().isEmpty && spans.isEmpty) continue;

          final attrs = leaf.style.attributes;
          FontWeight weight =
              attrs.containsKey('bold') ? FontWeight.bold : FontWeight.normal;
          FontStyle style = attrs.containsKey('italic') || isBlockquote
              ? FontStyle.italic
              : FontStyle.normal;

          spans.add(TextSpan(
            text: text,
            style: GoogleFonts.getFont(
              fontFamily,
              fontSize: isBlockquote ? fontSize + 2 : fontSize,
              fontWeight: weight,
              fontStyle: style,
              color: isBlockquote ? const Color(0xFFD4AF37) : c.onSurface,
              height: 1.8,
            ),
          ));
        }

        if (spans.isEmpty) {
          children.add(const SizedBox(height: 16));
          continue;
        }

        if (isFirstBlock) {
          final fullText = spans.map((e) => e.text ?? '').join();
          if (fullText.isNotEmpty) {
            final firstChar = fullText.substring(0, 1);
            final restText = fullText.substring(1);
            children.add(RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: firstChar,
                    style: GoogleFonts.getFont(
                      fontFamily,
                      fontSize: fontSize * 2.2,
                      fontWeight: FontWeight.bold,
                      color: c.primary,
                    ),
                  ),
                  TextSpan(
                    text: restText,
                    style: GoogleFonts.getFont(
                      fontFamily,
                      fontSize: fontSize,
                      color: c.onSurface,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ));
          }
          isFirstBlock = false;
        } else {
          if (isBlockquote) {
            children.add(Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: spans),
              ),
            ));
          } else {
            spans.insert(0, const TextSpan(text: '        '));
            children.add(RichText(text: TextSpan(children: spans)));
          }
        }
        children.add(const SizedBox(height: 16));
      } else if (node is quill.Block) {
        children.add(Text(
          node.toPlainText(),
          style: GoogleFonts.getFont(fontFamily,
              fontSize: fontSize, height: 1.8, color: c.onSurface),
        ));
        children.add(const SizedBox(height: 16));
      }
    }
    return children;
  }

  // ── Parse Delta into structured ParagraphBlocks ───────────────────

  List<_ParagraphBlock> _parseParagraphBlocks(
    Delta delta,
    double fontSize,
    String fontFamily,
    KotobaColors c,
  ) {
    final doc = quill.Document.fromDelta(delta);
    final blocks = <_ParagraphBlock>[];
    bool isFirstBlock = true;

    for (var node in doc.root.children) {
      if (node is quill.Line) {
        List<TextSpan> spans = [];
        bool isBlockquote = node.style.attributes.containsKey('blockquote');

        for (var leaf in node.children) {
          final text = leaf.toPlainText();
          if (text.trim().isEmpty && spans.isEmpty) continue;

          final attrs = leaf.style.attributes;
          FontWeight weight =
              attrs.containsKey('bold') ? FontWeight.bold : FontWeight.normal;
          FontStyle style = attrs.containsKey('italic') || isBlockquote
              ? FontStyle.italic
              : FontStyle.normal;

          spans.add(TextSpan(
            text: text,
            style: GoogleFonts.getFont(
              fontFamily,
              fontSize: isBlockquote ? fontSize + 2 : fontSize,
              fontWeight: weight,
              fontStyle: style,
              color: isBlockquote ? const Color(0xFFD4AF37) : c.onSurface,
              height: 1.8,
            ),
          ));
        }

        if (spans.isEmpty) {
          blocks.add(_ParagraphBlock(
            span: const TextSpan(text: ''),
            plainText: '',
            isEmpty: true,
          ));
          continue;
        }

        if (isFirstBlock) {
          final fullText = spans.map((e) => e.text ?? '').join();
          if (fullText.isNotEmpty) {
            final firstChar = fullText.substring(0, 1);
            final restText = fullText.substring(1);
            final dropCapSpan = TextSpan(
              children: [
                TextSpan(
                  text: firstChar,
                  style: GoogleFonts.getFont(
                    fontFamily,
                    fontSize: fontSize * 2.2,
                    fontWeight: FontWeight.bold,
                    color: c.primary,
                  ),
                ),
                TextSpan(
                  text: restText,
                  style: GoogleFonts.getFont(
                    fontFamily,
                    fontSize: fontSize,
                    color: c.onSurface,
                    height: 1.8,
                  ),
                ),
              ],
            );

            blocks.add(_ParagraphBlock(
              span: dropCapSpan,
              plainText: fullText,
              isBlockquote: isBlockquote,
            ));
          }
          isFirstBlock = false;
        } else {
          if (!isBlockquote) {
            spans.insert(0, const TextSpan(text: '        '));
          }
          final plainText = spans.map((e) => e.text ?? '').join();
          blocks.add(_ParagraphBlock(
            span: TextSpan(children: spans),
            plainText: plainText,
            isBlockquote: isBlockquote,
          ));
        }
      } else if (node is quill.Block) {
        final text = node.toPlainText();
        final span = TextSpan(
          text: text,
          style: GoogleFonts.getFont(
            fontFamily,
            fontSize: fontSize,
            color: c.onSurface,
            height: 1.8,
          ),
        );
        blocks.add(_ParagraphBlock(
          span: span,
          plainText: text,
        ));
      }
    }

    return blocks;
  }

  // ── Helper to slice a TextSpan at character boundaries ────────────

  TextSpan _sliceTextSpan(TextSpan span, int targetStart, int targetEnd) {
    int currentOffset = 0;

    TextSpan? slice(TextSpan s) {
      final text = s.text;
      final children = s.children;

      String? newText;
      List<InlineSpan>? newChildren;

      if (text != null && text.isNotEmpty) {
        final startInThis = currentOffset;
        final endInThis = currentOffset + text.length;

        if (endInThis <= targetStart || startInThis >= targetEnd) {
          currentOffset = endInThis;
          return null;
        }

        final clampStart = (targetStart - startInThis).clamp(0, text.length);
        final clampEnd = (targetEnd - startInThis).clamp(0, text.length);

        newText = text.substring(clampStart, clampEnd);
        currentOffset = endInThis;
      }

      if (children != null && children.isNotEmpty) {
        final slicedChildren = <InlineSpan>[];
        for (final child in children) {
          if (child is TextSpan) {
            final sliced = slice(child);
            if (sliced != null) slicedChildren.add(sliced);
          } else {
            slicedChildren.add(child);
          }
        }
        if (slicedChildren.isNotEmpty) {
          newChildren = slicedChildren;
        }
      }

      if ((newText == null || newText.isEmpty) &&
          (newChildren == null || newChildren.isEmpty)) {
        return null;
      }

      return TextSpan(
        text: newText,
        children: newChildren,
        style: s.style,
        recognizer: s.recognizer,
        semanticsLabel: s.semanticsLabel,
      );
    }

    return slice(span) ?? const TextSpan(text: '');
  }

  // ── True Book Pagination Engine ───────────────────────────────────

  void _buildPages(
    Delta delta,
    String chapterTitle,
    double fontSize,
    String fontFamily,
    KotobaColors c,
  ) {
    final key =
        '$fontSize|$fontFamily|${chapterTitle.hashCode}|${delta.hashCode}|${MediaQuery.of(context).size}';
    if (key == _lastPageKey && _pageGroups.isNotEmpty) return;
    _lastPageKey = key;

    final viewportHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    const topPadding = 80.0;
    const bottomPadding = 80.0;
    const hPadding = 24.0;

    final availableHeight = viewportHeight - topPadding - bottomPadding;
    final availableWidth = screenWidth - hPadding * 2;

    if (availableHeight <= 100 || availableWidth <= 100) return;

    final blocks = _parseParagraphBlocks(delta, fontSize, fontFamily, c);

    // Measure title
    final titleWidget = Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        chapterTitle,
        style: TextStyle(
          fontFamily: 'Noto Serif JP',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: c.primary,
        ),
      ),
    );
    final textScaler = MediaQuery.textScalerOf(context);

    final titlePainter = TextPainter(
      text: TextSpan(
        text: chapterTitle,
        style: const TextStyle(
          fontFamily: 'Noto Serif JP',
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout(maxWidth: availableWidth);
    final titleHeight = titlePainter.height + 24;

    final pages = <List<Widget>>[];
    var currentPageWidgets = <Widget>[];
    double currentHeight = 0.0;

    // Page 1 starts with title
    currentPageWidgets.add(titleWidget);
    currentHeight += titleHeight;

    for (int bIdx = 0; bIdx < blocks.length; bIdx++) {
      var block = blocks[bIdx];

      if (block.isEmpty) {
        if (currentHeight + 16 <= availableHeight) {
          currentPageWidgets.add(const SizedBox(height: 16));
          currentHeight += 16;
        }
        continue;
      }

      TextSpan currentSpan = block.span;
      String currentPlainText = block.plainText;
      final isBlockquote = block.isBlockquote;
      final blockWidth = isBlockquote ? availableWidth - 48 : availableWidth;

      while (currentPlainText.isNotEmpty) {
        final painter = TextPainter(
          text: currentSpan,
          textDirection: TextDirection.ltr,
          textAlign: isBlockquote ? TextAlign.center : TextAlign.start,
          textScaler: textScaler,
        )..layout(maxWidth: blockWidth);

        final fullHeight = painter.height + 16;
        final remainingPageHeight = availableHeight - currentHeight;

        // Fits on current page
        if (fullHeight <= remainingPageHeight) {
          final widget = isBlockquote
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: currentSpan,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RichText(text: currentSpan),
                );
          currentPageWidgets.add(widget);
          currentHeight += fullHeight;
          break;
        }

        // Does NOT fit on current page: try splitting across pages
        if (remainingPageHeight >= 40.0 && currentPageWidgets.isNotEmpty) {
          final targetHeight =
              (remainingPageHeight - 16).clamp(20.0, availableHeight);
          final pos = painter
              .getPositionForOffset(Offset(blockWidth, targetHeight));
          int rawCut = pos.offset;

          int cutIndex = rawCut;
          if (rawCut < currentPlainText.length) {
            final spaceIndex = currentPlainText.lastIndexOf(' ', rawCut);
            if (spaceIndex > 0 && spaceIndex > rawCut - 40) {
              cutIndex = spaceIndex + 1;
            }
          }

          if (cutIndex > 0 && cutIndex < currentPlainText.length) {
            var firstPartSpan = _sliceTextSpan(currentSpan, 0, cutIndex);
            
            // Re-measure to guarantee it fits
            final splitPainter = TextPainter(
              text: firstPartSpan,
              textDirection: TextDirection.ltr,
              textAlign: isBlockquote ? TextAlign.center : TextAlign.start,
              textScaler: textScaler,
            )..layout(maxWidth: blockWidth);

            while (splitPainter.height + 16 > remainingPageHeight && cutIndex > 0) {
              final spaceIndex = currentPlainText.lastIndexOf(' ', cutIndex - 1);
              if (spaceIndex > 0) {
                cutIndex = spaceIndex;
                firstPartSpan = _sliceTextSpan(currentSpan, 0, cutIndex);
                splitPainter.text = firstPartSpan;
                splitPainter.layout(maxWidth: blockWidth);
              } else {
                cutIndex -= 1;
                firstPartSpan = _sliceTextSpan(currentSpan, 0, cutIndex);
                splitPainter.text = firstPartSpan;
                splitPainter.layout(maxWidth: blockWidth);
              }
            }

            final secondPartSpan =
                _sliceTextSpan(currentSpan, cutIndex, currentPlainText.length);

            final widget = isBlockquote
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: firstPartSpan,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RichText(text: firstPartSpan),
                  );

            currentPageWidgets.add(widget);

            pages.add(currentPageWidgets);
            currentPageWidgets = <Widget>[];
            currentHeight = 0.0;

            currentSpan = secondPartSpan;
            currentPlainText = currentPlainText.substring(cutIndex);
            continue;
          }
        }

        // If remaining space on current page is too small, push to next page
        if (currentPageWidgets.isNotEmpty) {
          pages.add(currentPageWidgets);
          currentPageWidgets = <Widget>[];
          currentHeight = 0.0;
        } else {
          // Current page is empty and block still exceeds availableHeight: force split
          final targetHeight = (availableHeight - 16).clamp(40.0, availableHeight);
          final pos = painter
              .getPositionForOffset(Offset(blockWidth, targetHeight));
          int rawCut = pos.offset;
          int cutIndex = rawCut;
          if (rawCut < currentPlainText.length) {
            final spaceIndex = currentPlainText.lastIndexOf(' ', rawCut);
            if (spaceIndex > 0 && spaceIndex > rawCut - 40) {
              cutIndex = spaceIndex + 1;
            }
          }
          if (cutIndex <= 0) {
            cutIndex = (currentPlainText.length / 2)
                .floor()
                .clamp(1, currentPlainText.length);
          }

          var firstPartSpan = _sliceTextSpan(currentSpan, 0, cutIndex);

          final splitPainter = TextPainter(
            text: firstPartSpan,
            textDirection: TextDirection.ltr,
            textAlign: isBlockquote ? TextAlign.center : TextAlign.start,
            textScaler: textScaler,
          )..layout(maxWidth: blockWidth);

          while (splitPainter.height + 16 > availableHeight && cutIndex > 0) {
            final spaceIndex = currentPlainText.lastIndexOf(' ', cutIndex - 1);
            if (spaceIndex > 0) {
              cutIndex = spaceIndex;
              firstPartSpan = _sliceTextSpan(currentSpan, 0, cutIndex);
              splitPainter.text = firstPartSpan;
              splitPainter.layout(maxWidth: blockWidth);
            } else {
              cutIndex -= 1;
              firstPartSpan = _sliceTextSpan(currentSpan, 0, cutIndex);
              splitPainter.text = firstPartSpan;
              splitPainter.layout(maxWidth: blockWidth);
            }
          }

          final secondPartSpan =
              _sliceTextSpan(currentSpan, cutIndex, currentPlainText.length);

          final widget = isBlockquote
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: firstPartSpan,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RichText(text: firstPartSpan),
                );

          currentPageWidgets.add(widget);
          pages.add(currentPageWidgets);
          currentPageWidgets = <Widget>[];
          currentHeight = 0.0;

          currentSpan = secondPartSpan;
          currentPlainText = currentPlainText.substring(cutIndex);
        }
      }
    }

    if (currentPageWidgets.isNotEmpty) {
      pages.add(currentPageWidgets);
    }

    if (pages.isEmpty) {
      pages.add([titleWidget]);
    }

    setState(() {
      _pageGroups = pages;
      if (_currentPage >= pages.length) {
        _currentPage = 0;
      }
    });
  }

  // ── Save / load progress ─────────────────────────────────────────

  Future<void> _saveProgress(
      String workId, String chapterId, double scrollOffset, int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final all = prefs.getString('reading_progress') ?? '{}';
    final map = Map<String, dynamic>.from(jsonDecode(all));
    map[workId] = {
      'chapterId': chapterId, 
      'scrollOffset': scrollOffset,
      'pageIndex': pageIndex,
    };
    await prefs.setString('reading_progress', jsonEncode(map));
  }

  Map<String, dynamic>? _loadProgress(String workId) {
    final all = ref
            .read(sharedPreferencesProvider)
            .getString('reading_progress') ??
        '{}';
    final map = jsonDecode(all) as Map<String, dynamic>;
    return map[workId] as Map<String, dynamic>?;
  }

  Future<bool> _onWillPop(String workId, String chapterId) async {
    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

    final c = KotobaColors.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Guardar avance',
            style: TextStyle(color: c.onSurface)),
        content: Text('¿Quieres guardar tu avance antes de salir?',
            style: TextStyle(color: c.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('No guardar',
                style: TextStyle(color: c.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveProgress(workId, chapterId, scrollOffset, _currentPage);
      return true;
    }
    return true; // We always pop the screen even if they don't save
  }

  // ── Auto-navigate to Next Chapter ────────────────────────────────

  Future<void> _goToNextChapter(String workId) async {
    if (_isNavigatingToNext) return;
    
    final workDetailState = ref.read(workDetailViewModelProvider(workId)).value;
    if (workDetailState == null) return;
    
    final chapters = workDetailState.chapters;
    final currentIndex = chapters.indexWhere((c) => c.id == widget.chapterId);
    
    if (currentIndex != -1 && currentIndex < chapters.length - 1) {
      _isNavigatingToNext = true;
      final nextChapter = chapters[currentIndex + 1];
      
      final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
      await _saveProgress(workId, widget.chapterId, scrollOffset, _currentPage);

      if (mounted) {
        context.pushReplacement('/works/$workId/chapters/${nextChapter.id}');
      }
    }
  }

  Future<void> _goToPreviousChapter(String workId) async {
    if (_isNavigatingToNext) return;
    
    final workDetailState = ref.read(workDetailViewModelProvider(workId)).value;
    if (workDetailState == null) return;
    
    final chapters = workDetailState.chapters;
    final currentIndex = chapters.indexWhere((c) => c.id == widget.chapterId);
    
    if (currentIndex > 0) {
      _isNavigatingToNext = true;
      final prevChapter = chapters[currentIndex - 1];
      
      final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
      await _saveProgress(workId, widget.chapterId, scrollOffset, _currentPage);

      if (mounted) {
        context.pushReplacement('/works/$workId/chapters/${prevChapter.id}');
      }
    }
  }

  bool _onScrollNotification(ScrollUpdateNotification scrollInfo, String workId) {
    if (scrollInfo.metrics.pixels > scrollInfo.metrics.maxScrollExtent + 60) {
      _goToNextChapter(workId);
    } else if (scrollInfo.metrics.pixels < scrollInfo.metrics.minScrollExtent - 60) {
      _goToPreviousChapter(workId);
    }
    return false;
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterContentProvider(widget.chapterId));
    final prefs = ref.watch(readerPreferencesProvider);
    final c = KotobaColors.of(context);

    KotobaTypography.readerFontFamily = prefs.fontFamily;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (widget.workId != null) {
          final shouldPop = await _onWillPop(widget.workId!, widget.chapterId);
          if (shouldPop && context.mounted) {
            context.pop();
          }
        } else {
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: c.background,
        body: chapterAsync.when(
          loading: () => const Center(child: KotobaLoading()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (chapter) {
            if (!_viewCounted && chapter.workId.isNotEmpty) {
              _viewCounted = true;
              ref
                  .read(contentRepositoryProvider)
                  .incrementView(chapter.workId);
              // Invalidate to refresh stats, but we also watch it below to ensure it loads
              ref.invalidate(
                  workDetailViewModelProvider(chapter.workId));
            }

            final workId = widget.workId ?? chapter.workId;
            // Watch work details so we have the chapters list ready for auto-navigation
            ref.watch(workDetailViewModelProvider(workId));

            if (!_progressLoaded) {
              _progressLoaded = true;
              final progress = _loadProgress(workId);
              if (progress != null && progress['pageIndex'] is num) {
                _currentPage = (progress['pageIndex'] as num).toInt();
                _pageController.dispose();
                _pageController = PageController(initialPage: _currentPage);
              }
            }

            // Parse delta once
            final delta = _parseDelta(chapter.content);
            final chapterWidgets = _buildChapterWidgetsDelta(
                delta, prefs.fontSize, prefs.fontFamily, c);

            // Build pages for page mode
            if (prefs.readingMode == ReadingMode.page) {
              _buildPages(delta, chapter.title,
                  prefs.fontSize, prefs.fontFamily, c);
            } else {
              _lastPageKey = '';
              _pageGroups = [];
            }

            // Restore scroll position for cascade mode
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (prefs.readingMode != ReadingMode.cascade) return;
              if (!_scrollController.hasClients) return;
              final progress = _loadProgress(workId);
              if (progress != null &&
                  progress['scrollOffset'] is num) {
                final offset =
                    (progress['scrollOffset'] as num).toDouble();
                if (offset > 0 &&
                    offset <=
                        _scrollController.position.maxScrollExtent) {
                  _scrollController.jumpTo(offset);
                }
              }
            });

            return GestureDetector(
              onTap: _toggleOverlay,
              child: Stack(
                children: [
                  // ── Content area ──
                  if (prefs.readingMode == ReadingMode.page)
                    _buildPageView(c, chapter.title, chapterWidgets, workId)
                  else
                    _buildCascadeView(c, chapter.title, chapterWidgets, workId),

                  // ── Page indicator (page mode) ──
                  if (prefs.readingMode == ReadingMode.page &&
                      _pageGroups.length > 1)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _showOverlay ? 1 : 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: c.background
                                    .withValues(alpha: 0.8),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_currentPage + 1} / ${_pageGroups.length}',
                                style: KotobaTypography.labelSm
                                    .copyWith(color: c.onSurface),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Top overlay bar ──
                  _buildTopBar(c, prefs, workId),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Cascade (scroll) view ─────────────────────────────────────────

  Widget _buildCascadeView(
      KotobaColors c, String title, List<Widget> chapterWidgets, String workId) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (n) => _onScrollNotification(n, workId),
      child: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Noto Serif JP',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: c.primary,
            ),
          ),
          const SizedBox(height: 48),
          ...chapterWidgets,
        ],
      ),
    );
  }

  // ── Page view ─────────────────────────────────────────────────────

  Widget _buildPageView(
      KotobaColors c, String title, List<Widget> chapterWidgets, String workId) {
    if (_pageGroups.isEmpty) {
      return const Center(child: KotobaLoading());
    }

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (n) => _onScrollNotification(n, workId),
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: _pageGroups.length,
        onPageChanged: (p) => setState(() => _currentPage = p),
        itemBuilder: (_, i) {
        final pageWidgets = _pageGroups[i];
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: pageWidgets,
            ),
          ),
        );
      },
    ));
  }

  // ── Top bar ───────────────────────────────────────────────────────

  Widget _buildTopBar(
      KotobaColors c, ReaderPreferences prefs, String workId) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      top: _showOverlay ? 0 : -100,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        decoration: BoxDecoration(
          color: c.background.withValues(alpha: 0.9),
          border: Border(
            bottom: BorderSide(
              color: c.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (widget.workId != null) {
                  final shouldPop = await _onWillPop(widget.workId!, widget.chapterId);
                  if (shouldPop && mounted && context.canPop()) {
                    context.pop();
                  }
                } else {
                  if (mounted && context.canPop()) context.pop();
                }
              },
            ),
            const Spacer(),
            // ── Reading mode toggle ──
            PopupMenuButton<ReadingMode>(
              icon: Icon(
                prefs.readingMode == ReadingMode.page
                    ? Icons.chrome_reader_mode
                    : Icons.vertical_align_bottom,
                color: c.onSurfaceVariant,
              ),
              color: c.surfaceHigh,
              onSelected: (mode) {
                setState(() {
                  _lastPageKey = '';
                  _pageGroups = [];
                  _currentPage = 0;
                  _pageController = PageController();
                });
                ref
                    .read(readerPreferencesProvider.notifier)
                    .setReadingMode(mode);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: ReadingMode.cascade,
                  child: Row(
                    children: [
                      Icon(
                        Icons.vertical_align_bottom,
                        size: 20,
                        color: prefs.readingMode == ReadingMode.cascade
                            ? c.primary
                            : c.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text('Cascada',
                          style: TextStyle(color: c.onSurface)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ReadingMode.page,
                  child: Row(
                    children: [
                      Icon(
                        Icons.chrome_reader_mode,
                        size: 20,
                        color: prefs.readingMode == ReadingMode.page
                            ? c.primary
                            : c.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text('Página',
                          style: TextStyle(color: c.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.text_format, color: c.onSurfaceVariant),
              onPressed: _showFontSettings,
            ),
          ],
        ),
      ),
    );
  }
}
