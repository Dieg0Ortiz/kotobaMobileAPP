import 'dart:convert';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
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
  QuillController? _quillCtrl;
  String? _lastContent;

  @override
  void dispose() {
    _quillCtrl?.dispose();
    super.dispose();
  }

  Document _buildDocument(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        final delta = Delta.fromJson(decoded);
        return Document.fromDelta(delta);
      }
    } catch (_) {}
    return Document()..insert(0, content);
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

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterContentProvider(widget.chapterId));
    final prefs = ref.watch(readerPreferencesProvider);
    
    // Sync the global KotobaTypography reader font family so the rest of the app knows about it.
    KotobaTypography.readerFontFamily = prefs.fontFamily;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: chapterAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (chapter) {
          if (chapter.content != _lastContent) {
            _lastContent = chapter.content;
            _quillCtrl?.dispose();
            _quillCtrl = QuillController(
              document: _buildDocument(chapter.content),
              readOnly: true,
              selection: const TextSelection.collapsed(offset: 0),
            );
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
                    const SizedBox(height: 32),
                    if (_quillCtrl != null)
                      QuillEditor.basic(
                        controller: _quillCtrl!,
                        config: QuillEditorConfig(
                          padding: EdgeInsets.zero,
                          scrollable: false,
                          autoFocus: false,
                          showCursor: false,
                          enableInteractiveSelection: true,
                          customStyles: DefaultStyles(
                            paragraph: DefaultTextBlockStyle(
                              GoogleFonts.getFont(
                                prefs.fontFamily,
                                fontSize: prefs.fontSize,
                                height: 1.8,
                                color: AppColors.onSurface,
                              ),
                              const HorizontalSpacing(0, 0),
                              const VerticalSpacing(6, 0),
                              const VerticalSpacing(0, 0),
                              null,
                            ),
                          ),
                        ),
                      ),
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
          );
        },
      ),
    );
  }
}
