import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../reader/data/repositories/content_repository_impl.dart';

class ChapterEditorScreen extends ConsumerStatefulWidget {
  final String workId;
  final String? chapterId;

  const ChapterEditorScreen({required this.workId, this.chapterId, super.key});

  @override
  ConsumerState<ChapterEditorScreen> createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends ConsumerState<ChapterEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _saving = false;
  bool _dirty = false;
  bool _saved = false;
  String? _currentChapterId;
  Timer? _autoSaveTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentChapterId = widget.chapterId;
    _titleCtrl.addListener(_onChanged);
    _contentCtrl.addListener(_onChanged);
    if (_currentChapterId != null) _loadChapter();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
    _titleCtrl.removeListener(_onChanged);
    _contentCtrl.removeListener(_onChanged);
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() => _dirty = true);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      if (_dirty) _save(status: 'draft', stay: true);
    });
  }

  int get _wordCount {
    final text = _contentCtrl.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  Future<void> _loadChapter() async {
    final api = ref.read(apiClientProvider);
    final repo = ContentRepositoryImpl(api);
    final result = await repo.getChapter(_currentChapterId!);
    result.fold(
      (_) {},
      (chapter) {
        _titleCtrl.text = chapter.title;
        _contentCtrl.text = chapter.content;
        setState(() => _dirty = false);
      },
    );
  }

  Future<void> _save({required String status, bool stay = false}) async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final api = ref.read(apiClientProvider);
    final repo = ContentRepositoryImpl(api);

    final body = {
      'work_id': widget.workId,
      'title': _titleCtrl.text.trim(),
      'content': _contentCtrl.text,
      'status': status,
    };

    final result = _currentChapterId != null
        ? await repo.updateChapter(_currentChapterId!, body)
        : await repo.createChapter(body);

    setState(() {
      _saving = false;
      _dirty = false;
      _saved = true;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (chapter) {
        _currentChapterId ??= chapter.id;
        ScaffoldMessenger.of(context).clearSnackBars();
        if (stay) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status == 'published' ? 'Publicado' : 'Guardado'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );

    if (!stay) {
      if (context.mounted) context.pop();
    }
  }

  Future<bool> _onWillPop() async {
    if (_dirty) {
      await _save(status: 'draft', stay: true);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onWillPop();
        if (context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _onWillPop();
              if (context.mounted) context.pop();
            },
          ),
          title: Text(
            _currentChapterId != null ? 'Editar Capítulo' : 'Nuevo Capítulo',
            style: KotobaTypography.headlineMd,
          ),
          actions: [
            if (_dirty)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Sin guardar', style: KotobaTypography.labelXs.copyWith(color: Colors.white, fontSize: 10)),
              ),
            if (_saved && !_dirty)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.action,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Guardado', style: KotobaTypography.labelXs.copyWith(color: Colors.white, fontSize: 10)),
              ),
            TextButton(
              onPressed: _saving ? null : () => _save(status: 'draft'),
              child: Text('BORRADOR',
                  style: KotobaTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: _saving ? null : () => _save(status: 'published'),
              child: Text('PUBLICAR',
                  style: KotobaTypography.labelSm.copyWith(color: AppColors.action, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    style: KotobaTypography.headlineMd.copyWith(height: 1.3),
                    decoration: const InputDecoration(
                      hintText: 'Título del capítulo',
                      border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outlineVariant)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.action)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$_wordCount palabras',
                      style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentCtrl,
                    maxLines: null,
                    style: KotobaTypography.bodyMd.copyWith(height: 1.8),
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu capítulo aquí...\n\nSin límite de palabras.',
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    textAlignVertical: TextAlignVertical.top,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
