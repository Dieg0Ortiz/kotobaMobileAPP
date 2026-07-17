import 'dart:async';
import 'dart:convert';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../reader/data/repositories/content_repository_impl.dart';
import '../../../reader/presentation/providers/reader_providers.dart';
import '../providers/write_providers.dart';
import 'my_stories_screen.dart';

class ChapterEditorScreen extends ConsumerStatefulWidget {
  final String workId;
  final String? chapterId;

  const ChapterEditorScreen({required this.workId, this.chapterId, super.key});

  @override
  ConsumerState<ChapterEditorScreen> createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends ConsumerState<ChapterEditorScreen> {
  final _titleCtrl = TextEditingController();
  late QuillController _quillCtrl;
  late FocusNode _focusNode;
  late ScrollController _scrollCtrl;
  bool _saving = false;
  bool _dirty = false;
  bool _saved = false;
  bool _autoSaveFlash = false;
  String? _currentChapterId;
  Timer? _autoSaveTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentChapterId = widget.chapterId;
    _focusNode = FocusNode();
    _scrollCtrl = ScrollController();
    _quillCtrl = QuillController.basic();
    _titleCtrl.addListener(_onChanged);
    _quillCtrl.addListener(_onChanged);
    if (_currentChapterId != null) _loadChapter();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
    _titleCtrl.removeListener(_onChanged);
    _quillCtrl.removeListener(_onChanged);
    _titleCtrl.dispose();
    _quillCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() => _dirty = true);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 10), () {
      if (_dirty && !_saving) _save(status: 'draft', stay: true);
    });
  }

  int get _wordCount {
    final text = _quillCtrl.document.toPlainText().trim();
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
        _loadContent(chapter.content);
        setState(() => _dirty = false);
      },
    );
  }

  void _loadContent(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final delta = Delta.fromJson(decoded);
        _quillCtrl.document = Document.fromDelta(delta);
        return;
      }
    } catch (_) {}
    final delta = Delta()..insert(raw);
    _quillCtrl.document = Document.fromDelta(delta);
  }

  Future<void> _save({required String status, bool stay = false}) async {
    if (_saving) return;
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final deltaJson = jsonEncode(_quillCtrl.document.toDelta().toJson());

    final api = ref.read(apiClientProvider);
    final repo = ContentRepositoryImpl(api);

    final body = {
      'work_id': widget.workId,
      'title': _titleCtrl.text.trim(),
      'content': deltaJson,
      'status': status,
    };

    final result = _currentChapterId != null
        ? await repo.updateChapter(_currentChapterId!, body)
        : await repo.createChapter(body);

    // Forzar actualización del 'updated_at' de la obra principal para que suba en "Seguir escribiendo"
    if (result.isRight()) {
      final workRepo = ref.read(workRepositoryProvider);
      await workRepo.updateWork(widget.workId, {'updated_at': DateTime.now().toIso8601String()});
    }

    result.fold(
      (failure) {
        setState(() => _saving = false);
        if (!stay) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        }
      },
      (chapter) {
        _currentChapterId ??= chapter.id;
        _invalidateProviders();
        setState(() {
          _saving = false;
          _dirty = false;
          _saved = true;
          _autoSaveFlash = true;
        });
        if (!stay) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status == 'published' ? 'Publicado' : 'Guardado'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _autoSaveFlash = false);
        });
      },
    );

    if (!stay && mounted && context.canPop()) context.pop();
  }

  Future<void> _onPreview() async {
    await _save(status: 'draft', stay: true);
    if (_currentChapterId == null || !mounted) return;
    context.push('/works/${widget.workId}/chapters/$_currentChapterId');
  }

  void _onHistory(KotobaColors c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: const Text('Historial de revisiones'),
        content: const Text('Esta función se encuentra en desarrollo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _onDelete(KotobaColors c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: const Text('Eliminar capítulo'),
        content: const Text('¿Estás seguro de que deseas eliminar este capítulo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: c.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: TextStyle(color: c.error)),
          ),
        ],
      ),
    );

    if (confirm != true || _currentChapterId == null) {
      if (confirm == true && mounted && context.canPop()) context.pop();
      return;
    }

    final api = ref.read(apiClientProvider);
    final repo = ContentRepositoryImpl(api);
    final result = await repo.deleteChapter(_currentChapterId!);
    if (mounted) {
      result.fold(
        (l) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${l.message}'))),
        (_) {
          _invalidateProviders();
          if (context.canPop()) context.pop();
        },
      );
    }
  }

  void _invalidateProviders() {
    ref.invalidate(trendingWorksProvider);
    ref.invalidate(recommendedWorksProvider);
    ref.invalidate(searchResultsProvider);
    ref.invalidate(currentProfileProvider);
    ref.invalidate(authorDashboardProvider);
    ref.invalidate(myWorksProvider);
    ref.invalidate(writeDashboardProvider);
    ref.invalidate(workDetailViewModelProvider(widget.workId));
    ref.invalidate(workCommentsProvider(widget.workId));
    if (_currentChapterId != null) {
      ref.invalidate(chapterContentProvider(_currentChapterId!));
    }
  }

  Future<bool> _onWillPop() async {
    if (_dirty) {
      await _save(status: 'draft', stay: true);
    }
    return true;
  }

  bool _hasAttr(Attribute? attr) {
    if (attr == null) return false;
    final style = _quillCtrl.getSelectionStyle();
    return style.attributes.containsKey(attr.key);
  }

  void _onFormat(Attribute attr) {
    if (_hasAttr(attr)) {
      _quillCtrl.formatSelection(Attribute.clone(attr, null));
    } else {
      _quillCtrl.formatSelection(attr);
    }
  }

  String? _currentAlignment() {
    final style = _quillCtrl.getSelectionStyle();
    final align = style.attributes['align'];
    if (align == null) return null;
    return align.value as String?;
  }

  IconData get _alignmentIcon {
    return switch (_currentAlignment()) {
      'center' => Icons.format_align_center,
      'right' => Icons.format_align_right,
      _ => Icons.format_align_left,
    };
  }

  String get _alignmentLabel {
    return switch (_currentAlignment()) {
      'center' => 'Centro',
      'right' => 'Derecha',
      _ => 'Izquierda',
    };
  }

  void _cycleAlignment() {
    final current = _currentAlignment();
    final next = switch (current) {
      null => 'center',
      'center' => 'right',
      'right' => 'left',
      _ => null,
    };
    _quillCtrl.formatSelection(
      next != null ? Attribute.fromKeyValue('align', next) : Attribute.fromKeyValue('align', null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onWillPop();
        if (context.mounted && context.canPop()) context.pop();
      },
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(c),
              _buildProgressBar(c),
              Expanded(
                child: _buildEditorArea(c),
              ),
              _buildToolbar(c),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(KotobaColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _onWillPop();
              if (mounted && context.canPop()) context.pop();
            },
          ),
          Expanded(
            child: Text(
              'Crear',
              style: KotobaTypography.headlineMd.copyWith(
                color: c.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: _saving ? null : () => _save(status: 'published'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _saving ? 'PUBLICANDO...' : 'PUBLICAR',
                style: KotobaTypography.labelMd.copyWith(
                  color: _saving ? c.onSurfaceVariant : c.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: c.onSurfaceVariant),
            color: c.surfaceHigh,
            onSelected: (val) {
              if (val == 'save') _save(status: 'draft', stay: true);
              if (val == 'preview') _onPreview();
              if (val == 'history') _onHistory(c);
              if (val == 'delete') _onDelete(c);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'save', child: Text('Guardar', style: TextStyle(color: c.onSurface))),
              PopupMenuItem(value: 'preview', child: Text('Vista previa', style: TextStyle(color: c.onSurface))),
              PopupMenuItem(value: 'history', child: Text('Historial de revisiones', style: TextStyle(color: c.onSurface))),
              PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: c.onSurface))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(KotobaColors c) {
    return SizedBox(
      height: 2,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: c.surfaceHigh),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 100,
            child: ColoredBox(color: c.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorArea(KotobaColors c) {
    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          SizedBox(
            width: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMediaPlaceholder(c),
                const SizedBox(height: 24),
                _buildTitleField(c),
                const SizedBox(height: 16),
                _buildContentEditor(c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPlaceholder(KotobaColors c) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: c.outlineVariant.withValues(alpha: 0.3),
            style: BorderStyle.solid, // Simulated dashed via minimal outline
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: c.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para añadir medios gráficos',
              style: KotobaTypography.labelSm.copyWith(
                color: c.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(KotobaColors c) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: c.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: _titleCtrl,
        style: TextStyle(
          fontFamily: 'Noto Serif JP',
          fontSize: 26,
          fontWeight: FontWeight.w400,
          color: c.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Ponle un título a esta parte',
          hintStyle: TextStyle(
            fontFamily: 'Noto Serif JP',
            fontSize: 26,
            fontWeight: FontWeight.w400,
            color: c.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildContentEditor(KotobaColors c) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                QuillEditor.basic(
                  controller: _quillCtrl,
                  focusNode: _focusNode,
                  scrollController: ScrollController(),
                  config: const QuillEditorConfig(
                    placeholder: 'Escribe tu historia aquí...',
                    expands: false,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              '$_wordCount palabras',
              style: KotobaTypography.labelXs.copyWith(
                color: c.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(KotobaColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ToolbarBtn(
              icon: Icons.format_bold,
              active: _hasAttr(Attribute.bold),
              onTap: () => _onFormat(Attribute.bold),
              c: c,
            ),
            _ToolbarBtn(
              icon: Icons.format_italic,
              active: _hasAttr(Attribute.italic),
              onTap: () => _onFormat(Attribute.italic),
              c: c,
            ),
            _ToolbarBtn(
              icon: Icons.format_underline,
              active: _hasAttr(Attribute.underline),
              onTap: () => _onFormat(Attribute.underline),
              c: c,
            ),
            _ToolbarBtn(
              icon: _alignmentIcon,
              active: _currentAlignment() != null,
              onTap: _cycleAlignment,
              c: c,
            ),
            _ToolbarBtn(
              icon: Icons.format_list_bulleted,
              active: _hasAttr(Attribute.ul),
              onTap: () => _onFormat(Attribute.ul),
              c: c,
            ),
            _ToolbarBtn(
              icon: Icons.format_quote,
              active: _hasAttr(Attribute.blockQuote),
              onTap: () => _onFormat(Attribute.blockQuote),
              c: c,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final KotobaColors c;

  const _ToolbarBtn({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(
          icon,
          size: 24,
          color: active ? c.primary : c.onSurfaceVariant,
        ),
      ),
    );
  }
}
