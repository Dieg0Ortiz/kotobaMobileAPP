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
import '../../../../core/widgets/common/drop_cap_text.dart';
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

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  bool _showOverlay = true;
  bool _viewCounted = false;
  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  List<Widget> _cachedPages = [];
  int _currentPage = 0;
  bool _pagesBuilt = false;

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

  List<Widget> _buildChapterWidgetsDelta(Delta delta, double fontSize, String fontFamily, KotobaColors c) {

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
          FontWeight weight = attrs.containsKey('bold') ? FontWeight.bold : FontWeight.normal;
          FontStyle style = attrs.containsKey('italic') || isBlockquote ? FontStyle.italic : FontStyle.normal;
          
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
          String fullText = spans.map((e) => e.text).join();
          children.add(DropCapText(
            fullText,
            style: GoogleFonts.getFont(fontFamily, fontSize: fontSize, height: 1.8, color: c.onSurface),
            dropCapStyle: GoogleFonts.getFont(
              fontFamily, 
              fontSize: fontSize * 5.5,
              fontWeight: FontWeight.bold,
              color: c.onSurface,
            ),
            dropCapPadding: const EdgeInsets.only(right: 12.0, bottom: 4.0),
            indentation: const Offset(0, 20.0),
            forceNoDescent: true,
          ));
          isFirstBlock = false;
        } else {
          if (isBlockquote) {
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: spans),
                ),
              )
            );
          } else {
            spans.insert(0, const TextSpan(text: '        '));
            children.add(RichText(text: TextSpan(children: spans)));
          }
        }
        children.add(const SizedBox(height: 16));
      } else if (node is quill.Block) {
        children.add(Text(
          node.toPlainText(),
          style: GoogleFonts.getFont(fontFamily, fontSize: fontSize, height: 1.8, color: c.onSurface),
        ));
        children.add(const SizedBox(height: 16));
      }
    }
    return children;
  }

  // ── Page splitting by character-count estimation ─────────────────
  // Mirrors _buildChapterWidgetsDelta logic to produce one height entry per widget.
  List<Widget> _buildPagesReal(List<Widget> chapterWidgets, Delta delta, double fontSize, String fontFamily, KotobaColors c) {
    if (chapterWidgets.isEmpty) return [];

    final screenWidth = MediaQuery.of(context).size.width - 48;
    final viewportHeight = MediaQuery.of(context).size.height - (80 + 40); // top + bottom padding

    // Estimate height per paragraph using character count (no TextPainter, which
    // returns 0 when Google Fonts aren't loaded yet). Mirrors _buildChapterWidgetsDelta.
    final doc = quill.Document.fromDelta(delta);
    // chars per line approximation
    final avgCharWidth = fontSize * 0.55;
    final charsPerLine = (screenWidth / avgCharWidth).floor().clamp(1, 200);
    final heights = <double>[];
    bool isFirstBlock = true;

    for (var node in doc.root.children) {
      if (node is quill.Line) {
        final text = node.children.map((e) => e.toPlainText()).join();

        if (text.trim().isEmpty) {
          heights.add(16);
          continue;
        }

        final lines = (text.length / charsPerLine).ceil().clamp(1, 999);
        final h = lines * fontSize * 1.5 + 8 + 16; // paragraph + bottom gap

        if (isFirstBlock) {
          heights.add(h + 60); // extra for drop cap
          isFirstBlock = false;
        } else {
          heights.add(h);
        }
        heights.add(16); // SizedBox after paragraph
      } else if (node is quill.Block) {
        heights.add(fontSize * 1.8 + 16);
        heights.add(16);
      }
    }

    // If no measurements (unlikely), return one page with everything
    if (heights.isEmpty) {
      return [SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
        child: Column(children: chapterWidgets),
      )];
    }

    // Group into pages by accumulating measured heights
    final pages = <Widget>[];
    int startIdx = 0;
    while (startIdx < chapterWidgets.length) {
      double acc = 0;
      int endIdx = startIdx;
      while (endIdx < chapterWidgets.length) {
        final h = endIdx < heights.length ? heights[endIdx] : 16;
        if (acc + h > viewportHeight && endIdx > startIdx) break;
        acc += h;
        endIdx++;
      }
      if (endIdx == startIdx) {
        endIdx = startIdx + 1;
      }
      pages.add(Padding(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
        child: Column(children: chapterWidgets.sublist(startIdx, endIdx)),
      ));
      startIdx = endIdx;
    }

    return pages;
  }

  // ── Save progress ────────────────────────────────────────────────
  Future<void> _saveProgress(String workId, String chapterId, double scrollOffset) async {
    final prefs = await SharedPreferences.getInstance();
    final all = prefs.getString('reading_progress') ?? '{}';
    final map = Map<String, dynamic>.from(jsonDecode(all));
    map[workId] = {'chapterId': chapterId, 'scrollOffset': scrollOffset};
    await prefs.setString('reading_progress', jsonEncode(map));
  }

  Map<String, dynamic>? _loadProgress(String workId) {
    final all = ref.read(sharedPreferencesProvider).getString('reading_progress') ?? '{}';
    final map = jsonDecode(all) as Map<String, dynamic>;
    return map[workId] as Map<String, dynamic>?;
  }

  Future<bool> _onWillPop(String workId, String chapterId) async {
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar avance'),
        content: const Text('¿Quieres guardar tu avance antes de salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No guardar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveProgress(workId, chapterId, scrollOffset);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterContentProvider(widget.chapterId));
    final prefs = ref.watch(readerPreferencesProvider);
    final c = KotobaColors.of(context);
    
    KotobaTypography.readerFontFamily = prefs.fontFamily;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) return;
        if (widget.workId != null) {
          final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
          await _saveProgress(widget.workId!, widget.chapterId, scrollOffset);
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
              ref.read(contentRepositoryProvider).incrementView(chapter.workId);
              // Invalidate work detail so view count refreshes on return
              ref.invalidate(workDetailViewModelProvider(chapter.workId));
            }

            final workId = widget.workId ?? chapter.workId;

            // Parse delta once for both widget building and page measurement
            final delta = _parseDelta(chapter.content);
            final chapterWidgets = _buildChapterWidgetsDelta(delta, prefs.fontSize, prefs.fontFamily, c);

            // Build pages for page mode
            if (prefs.readingMode == ReadingMode.page && !_pagesBuilt) {
              _cachedPages = _buildPagesReal(chapterWidgets, delta, prefs.fontSize, prefs.fontFamily, c);
              _pagesBuilt = true;
            }
            if (prefs.readingMode == ReadingMode.cascade) {
              _pagesBuilt = false;
            }

            // Restore scroll once
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (prefs.readingMode != ReadingMode.cascade) return;
              if (!_scrollController.hasClients) return;
              final progress = _loadProgress(workId);
              if (progress != null && progress['scrollOffset'] is num) {
                final offset = (progress['scrollOffset'] as num).toDouble();
                if (offset > 0 && offset <= _scrollController.position.maxScrollExtent) {
                  _scrollController.jumpTo(offset);
                }
              }
            });

            return GestureDetector(
                onTap: _toggleOverlay,
                child: Stack(
                  children: [
                    // ── Content area ──
                    prefs.readingMode == ReadingMode.page
                        ? PageView.builder(
                            controller: _pageController,
                            itemCount: _cachedPages.length,
                            onPageChanged: (p) => setState(() => _currentPage = p),
                            itemBuilder: (_, i) => _cachedPages[i],
                          )
                        : ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
                            children: [
                              Text(
                                chapter.title,
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

                    // ── Page indicator (page mode) ──
                    if (prefs.readingMode == ReadingMode.page && _cachedPages.length > 1)
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: c.background.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_currentPage + 1} / ${_cachedPages.length}',
                                  style: KotobaTypography.labelSm.copyWith(color: c.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Top overlay bar ──
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      top: _showOverlay ? 0 : -80,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.only(top: 32),
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
                                  await _onWillPop(widget.workId!, widget.chapterId);
                                }
                                if (mounted && context.canPop()) context.pop();
                              },
                            ),
                            const Spacer(),
                            // ── Reading mode toggle ──
                            PopupMenuButton<ReadingMode>(
                              icon: Icon(
                                prefs.readingMode == ReadingMode.page ? Icons.chrome_reader_mode : Icons.vertical_align_bottom,
                              ),
                              onSelected: (mode) => ref.read(readerPreferencesProvider.notifier).setReadingMode(mode),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: ReadingMode.cascade,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.vertical_align_bottom,
                                        size: 20,
                                        color: prefs.readingMode == ReadingMode.cascade ? c.primary : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Cascada'),
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
                                        color: prefs.readingMode == ReadingMode.page ? c.primary : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Página'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
              );
          },
        ),
      ),
    );
  }
}
