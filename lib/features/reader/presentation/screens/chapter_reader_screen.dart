import 'dart:convert';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/drop_cap_text.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../providers/reader_providers.dart';
import '../widgets/font_settings_sheet.dart';

class ChapterReaderScreen extends ConsumerStatefulWidget {
  final String chapterId;

  const ChapterReaderScreen({required this.chapterId, super.key});

  @override
  ConsumerState<ChapterReaderScreen> createState() =>
      _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  bool _showOverlay = true;
  bool _viewCounted = false;

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

  List<Widget> _buildChapterWidgets(String content, double fontSize, String fontFamily) {
    Delta delta;
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        delta = Delta.fromJson(decoded);
      } else {
        delta = Delta()..insert(content);
      }
    } catch (_) {
      delta = Delta()..insert(content);
    }

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
              color: isBlockquote ? const Color(0xFFD4AF37) : AppColors.onSurface,
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
            style: GoogleFonts.getFont(fontFamily, fontSize: fontSize, height: 1.8, color: AppColors.onSurface),
            dropCapStyle: GoogleFonts.getFont(
              fontFamily, 
              fontSize: fontSize * 5.5, // Much larger letter
              fontWeight: FontWeight.bold,
              // Removed height: 1.0 to prevent cropping at the top
              color: AppColors.onSurface,
            ),
            dropCapPadding: const EdgeInsets.only(right: 12.0, bottom: 4.0),
            indentation: const Offset(0, 20.0), // Pushes the text down to align near the middle of the letter
            forceNoDescent: true, // Removes extra bottom padding from the letter
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
            // Add sangría (8 spaces)
            spans.insert(0, const TextSpan(text: '        '));
            children.add(RichText(text: TextSpan(children: spans)));
          }
        }
        children.add(const SizedBox(height: 16));
      } else if (node is quill.Block) {
        // Basic fallback for lists/blocks if they exist
        children.add(Text(
          node.toPlainText(),
          style: GoogleFonts.getFont(fontFamily, fontSize: fontSize, height: 1.8, color: AppColors.onSurface),
        ));
        children.add(const SizedBox(height: 16));
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterContentProvider(widget.chapterId));
    final prefs = ref.watch(readerPreferencesProvider);
    
    KotobaTypography.readerFontFamily = prefs.fontFamily;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: chapterAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (chapter) {
          if (!_viewCounted && chapter.workId.isNotEmpty) {
            _viewCounted = true;
            ref.read(contentRepositoryProvider).incrementView(chapter.workId);
          }

          return GestureDetector(
            onTap: _toggleOverlay,
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
                  children: [
                    Text(
                      chapter.title,
                      style: const TextStyle(
                        fontFamily: 'Noto Serif JP',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 48),
                    ..._buildChapterWidgets(chapter.content, prefs.fontSize, prefs.fontFamily),
                  ],
                ),
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
                          color:
                              AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () { if (context.canPop()) context.pop(); },
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
          );
        },
      ),
    );
  }
}
