import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../reader/data/repositories/content_repository_impl.dart';
import '../../../reader/domain/entities/chapter.dart';
import '../../../reader/presentation/providers/reader_providers.dart';
import '../providers/write_providers.dart';
import 'my_stories_screen.dart';

class EditStoryScreen extends ConsumerStatefulWidget {
  final String storyId;

  const EditStoryScreen({required this.storyId, super.key});

  @override
  ConsumerState<EditStoryScreen> createState() => _EditStoryScreenState();
}

class _EditStoryScreenState extends ConsumerState<EditStoryScreen> {
  // Story fields
  final _titleCtrl = TextEditingController();
  final _synopsisCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  bool isMature = false;
  bool isCompleted = false;
  bool _saving = false;
  bool _loading = true;
  String? _coverUrl;
  XFile? _localCoverFile;
  List<Chapter> _chapters = [];
  List<String> _tags = [];

  String? _actualWorkId;
  bool get _isNew => _actualWorkId == null;
  bool get _canPublish =>
      _titleCtrl.text.trim().isNotEmpty && _synopsisCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_onFieldChanged);
    _synopsisCtrl.addListener(_onFieldChanged);
    if (widget.storyId == 'new') {
      _actualWorkId = null;
      _loading = false;
    } else {
      _actualWorkId = widget.storyId;
      _loadWork();
    }
  }

  void _onFieldChanged() => setState(() {});

  @override
  void didUpdateWidget(covariant EditStoryScreen old) {
    super.didUpdateWidget(old);
    if (old.storyId != widget.storyId && widget.storyId != 'new') {
      _loading = true;
      _chapters = [];
      _actualWorkId = widget.storyId;
      _loadWork();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _synopsisCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWork() async {
    final repo = ref.read(workRepositoryProvider);
    final result = await repo.getWorkById(widget.storyId);
    result.fold(
      (_) {},
      (work) {
        _titleCtrl.text = work.title;
        _synopsisCtrl.text = work.synopsis;
        _tags = List<String>.from(work.tags);
        _tagsCtrl.text = work.tags.join(', ');
        _coverUrl = work.coverUrl;
        isCompleted = work.status == 'completed';
      },
    );
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    if (_actualWorkId == null) return;
    final api = ref.read(apiClientProvider);
    final repo = ContentRepositoryImpl(api);
    final result = await repo.getChapters(_actualWorkId!);
    result.fold(
      (_) {},
      (chapters) => setState(() => _chapters = chapters),
    );
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (file != null) setState(() => _localCoverFile = file);
  }

  Future<void> _uploadCover(String workId) async {
    if (_localCoverFile == null) return;
    try {
      final dio = ref.read(apiClientProvider).dio;
      final bytes = await _localCoverFile!.readAsBytes();
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: 'cover.jpg'),
      });
      final response = await dio.post('${ApiConstants.baseUrl}${ApiConstants.uploadCover}', data: formData);
      final url = response.data['url'] as String;
      await ref.read(workRepositoryProvider).updateWork(workId, {'cover_url': url});
      setState(() => _coverUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
      }
    }
  }

  Future<bool> _saveStory({required String status, bool replaceRoute = false}) async {
    final title = _titleCtrl.text.trim().isEmpty ? 'Historia sin título' : _titleCtrl.text.trim();
    setState(() => _saving = true);
    final repo = ref.read(workRepositoryProvider);
    final body = {
      'title': title,
      'synopsis': _synopsisCtrl.text.trim(),
      'tags': _tags,
      'genre': 'Sin género',
      'status': status,
      'language': 'es',
    };

    final workId = _actualWorkId ?? widget.storyId;
    final result = _isNew ? await repo.createWork(body) : await repo.updateWork(workId, body);
    setState(() => _saving = false);

    return result.fold(
      (failure) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
        return false;
      },
      (work) async {
        if (_isNew) {
          _actualWorkId = work.id;
          if (replaceRoute && mounted) context.replace('/write/edit/${work.id}');
        }
        if (_localCoverFile != null) await _uploadCover(work.id);
        _invalidateProviders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isNew ? 'Historia creada' : 'Guardado')));
        }
        if (!_isNew) _loadChapters();
        return true;
      },
    );
  }

  Future<bool> _saveDraft({bool replaceRoute = false}) {
    return _saveStory(status: 'draft', replaceRoute: replaceRoute);
  }

  Future<bool> _savePublished({bool replaceRoute = false}) async {
    if (_titleCtrl.text.trim().isEmpty || _synopsisCtrl.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa el título y la sinopsis antes de publicar')),
        );
      }
      return false;
    }
    return _saveStory(status: 'published', replaceRoute: replaceRoute);
  }

  Future<void> _onNewChapter() async {
    if (_isNew) {
      final saved = await _saveDraft(replaceRoute: true);
      if (!saved) return;
    }
    if (!mounted) return;
    await context.push('/write/edit/$_actualWorkId/chapter/new');
    if (mounted) _loadChapters();
  }

  /// Invalidates all cached providers that depend on works/stories data
  /// so that every screen reflects the latest changes immediately.
  void _invalidateProviders() {
    ref.invalidate(trendingWorksProvider);
    ref.invalidate(recommendedWorksProvider);
    ref.invalidate(searchResultsProvider);
    ref.invalidate(currentProfileProvider);
    ref.invalidate(authorDashboardProvider);
    // Invalidate entire family — clears cache for all author IDs
    ref.invalidate(myWorksProvider);
    ref.invalidate(writeDashboardProvider);
    if (_actualWorkId != null) {
      ref.invalidate(workDetailViewModelProvider(_actualWorkId!));
    }
  }

  Future<void> _onEditChapter(Chapter ch) async {
    await context.push('/write/edit/$_actualWorkId/chapter/${ch.id}');
    // Reload chapters after returning from editor
    if (mounted) _loadChapters();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() {
        _tags.add(trimmed);
        _tagsCtrl.text = _tags.join(', ');
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _tagsCtrl.text = _tags.join(', ');
    });
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              top: 0,
              bottom: MediaQuery.of(context).padding.bottom + 100,
            ),
            children: [
              _buildCoverSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Transform.translate(
                  offset: const Offset(0, -48),
                  child: Column(
                    children: [
                      _buildTitleSynopsisCard(),
                      const SizedBox(height: 24),
                      _buildSettingsCard(),
                      const SizedBox(height: 24),
                      _buildTagsCard(),
                      const SizedBox(height: 24),
                      _buildTableOfContentsCard(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom action bar for mobile
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.8),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
              onPressed: () => context.pop(),
            ),
            centerTitle: true,
            title: Text(
              'Crear',
              style: KotobaTypography.headlineMd.copyWith(
                color: AppColors.primary,
                letterSpacing: 3,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _saving ? null : () => _saveDraft(replaceRoute: true),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        'GUARDAR',
                        style: KotobaTypography.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cover Section ──────────────────────────────────────────────────

  Widget _buildCoverSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final hasCover = _localCoverFile != null || _coverUrl != null;

    return GestureDetector(
      onTap: _pickImage,
      child: SizedBox(
        height: screenHeight * 0.4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Container(color: AppColors.surfaceLow),

            // Cover image
            if (hasCover)
              Opacity(
                opacity: 0.4,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.saturation,
                  ),
                  child: _localCoverFile != null
                      ? (kIsWeb
                          ? Image.network(_localCoverFile!.path, fit: BoxFit.cover)
                          : Image.file(File(_localCoverFile!.path), fit: BoxFit.cover))
                      : CachedNetworkImage(
                          imageUrl: _coverUrl!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Add photo button
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 28,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AÑADIR PORTADA',
                    style: KotobaTypography.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Glass Card Wrapper ─────────────────────────────────────────────

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF131318).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.onSurface.withValues(alpha: 0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ── Title & Synopsis Card ──────────────────────────────────────────

  Widget _buildTitleSynopsisCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          Text(
            'Título de la historia',
            style: KotobaTypography.labelSm.copyWith(
              color: AppColors.primary,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 8),
          _buildStyledInput(
            controller: _titleCtrl,
            placeholder: 'Escribe un título cautivador...',
            style: KotobaTypography.headlineMd.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 24),

          // Synopsis field
          Text(
            'Sinopsis / Descripción',
            style: KotobaTypography.labelSm.copyWith(
              color: AppColors.primary,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 8),
          _buildStyledInput(
            controller: _synopsisCtrl,
            placeholder: '¿De qué trata tu historia? Atrae a los lectores con un buen resumen...',
            maxLines: 5,
            style: KotobaTypography.bodyMd,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledInput({
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
    TextStyle? style,
    Widget? prefixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
        color: AppColors.surfaceLowest,
      ),
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasFocus ? AppColors.primaryContainer : Colors.transparent,
                  width: hasFocus ? 2 : 0,
                ),
                boxShadow: hasFocus
                    ? [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                crossAxisAlignment:
                    maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 12),
                      child: prefixIcon,
                    ),
                  ],
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: maxLines,
                      style: style ?? KotobaTypography.bodyMd,
                      onSubmitted: onSubmitted,
                      decoration: InputDecoration(
                        hintText: placeholder,
                        hintStyle: (style ?? KotobaTypography.bodyMd).copyWith(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        filled: false,
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

  // ── Settings Card ──────────────────────────────────────────────────

  Widget _buildSettingsCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONFIGURACIÓN',
                  style: KotobaTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  height: 1,
                ),
              ],
            ),
          ),

          // Mature content toggle
          _buildToggleRow(
            title: 'Contenido Adulto',
            subtitle: 'Contiene escenas explícitas o violencia',
            value: isMature,
            activeColor: const Color(0xFFE07A5F),
            onChanged: (v) => setState(() => isMature = v),
          ),

          Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
            height: 1,
          ),

          // Completed story toggle
          _buildToggleRow(
            title: 'Historia Finalizada',
            subtitle: 'Marca la obra como completa',
            value: isCompleted,
            activeColor: AppColors.primaryContainer,
            onChanged: (v) => setState(() => isCompleted = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KotobaTypography.bodyMd),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: KotobaTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: activeColor,
            activeTrackColor: activeColor.withValues(alpha: 0.4),
            inactiveThumbColor: AppColors.onSurface,
            inactiveTrackColor: AppColors.surfaceHighest,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  // ── Tags Card ──────────────────────────────────────────────────────

  Widget _buildTagsCard() {
    final tagInputCtrl = TextEditingController();

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ETIQUETAS',
                style: KotobaTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
                height: 1,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tag input
          _buildStyledInput(
            controller: tagInputCtrl,
            placeholder: 'Añadir etiqueta y presionar enter...',
            style: KotobaTypography.bodyMd,
            prefixIcon: const Icon(
              Icons.sell_outlined,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
            onSubmitted: (value) {
              _addTag(value);
              tagInputCtrl.clear();
            },
          ),

          // Tags list
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: KotobaTypography.labelSm.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Table of Contents Card ─────────────────────────────────────────

  Widget _buildTableOfContentsCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TABLA DE\nCONTENIDOS',
                style: KotobaTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                  height: 1.4,
                ),
              ),
              Text(
                '${_chapters.length} Capítulo${_chapters.length == 1 ? '' : 's'}',
                style: KotobaTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
            height: 1,
          ),
          const SizedBox(height: 8),

          // Chapters list
          if (_chapters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Aún no hay capítulos.',
                  style: KotobaTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...List.generate(_chapters.length, (index) {
              final ch = _chapters[index];
              return _buildChapterItem(ch, index + 1);
            }),

          const SizedBox(height: 16),

          // Add chapter button
          GestureDetector(
            onTap: _onNewChapter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outlineVariant,
                  style: BorderStyle.solid,
                ),
                color: AppColors.surfaceLowest.withValues(alpha: 0.5),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 28,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agregar Capítulo',
                    style: KotobaTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterItem(Chapter chapter, int number) {
    final isPublished = chapter.status == 'published';
    return InkWell(
      onTap: () => _onEditChapter(chapter),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Chapter number
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                number.toString().padLeft(2, '0'),
                style: KotobaTypography.headlineMd.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Chapter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: KotobaTypography.bodyMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPublished
                        ? 'Publicado • ${chapter.wordCount} palabras'
                        : 'Borrador • ${chapter.wordCount} palabras',
                    style: KotobaTypography.labelSm.copyWith(
                      color: isPublished
                          ? AppColors.onSurfaceVariant
                          : const Color(0xFFE07A5F),
                    ),
                  ),
                ],
              ),
            ),

            // Edit icon
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              // Draft button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : () => _saveDraft(),
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    'Borrador',
                    style: KotobaTypography.labelMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: const BorderSide(color: AppColors.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Publish button
              Expanded(
                child: FilledButton.icon(
                  onPressed: (_saving || !_canPublish) ? null : () => _savePublished(replaceRoute: true),
                  icon: const Icon(Icons.publish, size: 18),
                  label: Text(
                    'Publicar',
                    style: KotobaTypography.labelMd.copyWith(
                      color: !_canPublish
                          ? AppColors.onSurfaceVariant
                          : AppColors.background,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: !_canPublish
                        ? AppColors.surfaceHigh
                        : AppColors.primaryContainer,
                    foregroundColor: !_canPublish
                        ? AppColors.onSurfaceVariant
                        : AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
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
