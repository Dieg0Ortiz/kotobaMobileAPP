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
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../reader/data/repositories/content_repository_impl.dart';
import '../../../reader/domain/entities/chapter.dart';
import '../../../reader/presentation/providers/reader_providers.dart';
import '../providers/write_providers.dart';
import 'my_stories_screen.dart';
import 'story_dashboard_screen.dart';

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
  List<String> _selectedGenres = [];

  String? _actualWorkId;
  bool get _isNew => _actualWorkId == null;
  bool get _canPublish =>
      _titleCtrl.text.trim().isNotEmpty &&
      _synopsisCtrl.text.trim().isNotEmpty &&
      _selectedGenres.isNotEmpty;

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
        _selectedGenres = work.genres.where(_availableGenres.contains).toList();
        _coverUrl = work.coverUrl;
        isCompleted = work.status == 'completed';
        isMature = work.isMature;
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
      (chapters) async {
        // For chapters with wordCount == 0, fetch full content to compute it
        final updated = <Chapter>[];
        for (final ch in chapters) {
          if (ch.wordCount == 0) {
            final fullResult = await repo.getChapter(ch.id);
            fullResult.fold(
              (_) => updated.add(ch),
              (fullChapter) {
                updated.add(fullChapter);
                // Backfill word_count on the backend so this is a one-time cost
                if (fullChapter.wordCount > 0) {
                  repo.updateChapter(ch.id, {
                    'word_count': fullChapter.wordCount,
                    'read_time_minutes': fullChapter.readTimeMinutes,
                  });
                }
              },
            );
          } else {
            updated.add(ch);
          }
        }
        if (mounted) setState(() => _chapters = updated);
      },
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
      'genres': _selectedGenres,
      'status': status,
      'language': 'es',
      'is_mature': isMature,
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
    ref.invalidate(myWorksProvider);
    ref.invalidate(writeDashboardProvider);
    ref.invalidate(workDetailViewModelProvider(widget.storyId));
    if (_actualWorkId != null) {
      ref.invalidate(workDetailViewModelProvider(_actualWorkId!));
      ref.invalidate(workCommentsProvider(_actualWorkId!));
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
    final c = KotobaColors.of(context);
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () { if (context.canPop()) context.pop(); }),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(c),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              top: 0,
              bottom: MediaQuery.of(context).padding.bottom + 100,
            ),
            children: [
              _buildCoverSection(c),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Transform.translate(
                  offset: const Offset(0, -48),
                  child: Column(
                    children: [
                      _buildTitleSynopsisCard(c),
                      const SizedBox(height: 24),
                      _buildSettingsCard(c),
                      const SizedBox(height: 24),
                      _buildGenresCard(c),
                      const SizedBox(height: 24),
                      _buildTagsCard(c),
                      const SizedBox(height: 24),
                      _buildTableOfContentsCard(c),
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
            child: _buildBottomBar(c),
          ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(KotobaColors c) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: c.surface.withValues(alpha: 0.8),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: c.onSurfaceVariant),
              onPressed: () { if (context.canPop()) context.pop(); },
            ),
            centerTitle: true,
            title: Text(
              _isNew ? 'Crear' : 'Editar',
              style: KotobaTypography.headlineMd.copyWith(
                color: c.primary,
                letterSpacing: 3,
              ),
            ),
            actions: [
              if (!_isNew)
                IconButton(
                  icon: Icon(Icons.analytics_outlined, color: c.primary),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDashboardScreen(storyId: widget.storyId)));
                  },
                ),
              TextButton(
                onPressed: _saving ? null : () => _saveDraft(replaceRoute: true),
                child: _saving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: c.primary,
                        ),
                      )
                    : Text(
                        'GUARDAR',
                        style: KotobaTypography.labelSm.copyWith(
                          color: c.primary,
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

  Widget _buildCoverSection(KotobaColors c) {
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
            Container(color: c.surfaceLow),

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
                    c.background,
                    c.background.withValues(alpha: 0.5),
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
                      color: c.surface.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: c.outlineVariant.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 28,
                      color: c.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AÑADIR PORTADA',
                    style: KotobaTypography.labelSm.copyWith(
                      color: c.onSurfaceVariant,
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

  Widget _glassCard(KotobaColors c, {required Widget child}) {
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
              color: c.onSurface.withValues(alpha: 0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ── Title & Synopsis Card ──────────────────────────────────────────

  Widget _buildTitleSynopsisCard(KotobaColors c) {
    return _glassCard(
      c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          Text(
            'Título de la historia',
            style: KotobaTypography.labelSm.copyWith(
              color: c.primary,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 8),
          _buildStyledInput(
            c,
            controller: _titleCtrl,
            placeholder: 'Escribe un título cautivador...',
            style: KotobaTypography.headlineMd.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 24),

          // Synopsis field
          Text(
            'Sinopsis / Descripción',
            style: KotobaTypography.labelSm.copyWith(
              color: c.primary,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 8),
          _buildStyledInput(
            c,
            controller: _synopsisCtrl,
            placeholder: '¿De qué trata tu historia? Atrae a los lectores con un buen resumen...',
            maxLines: 5,
            style: KotobaTypography.bodyMd,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledInput(
    KotobaColors c, {
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
        border: Border.all(color: c.outlineVariant),
        color: c.surfaceLowest,
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
                  color: hasFocus ? c.primaryContainer : Colors.transparent,
                  width: hasFocus ? 2 : 0,
                ),
                boxShadow: hasFocus
                    ? [
                        BoxShadow(
                          color: c.primaryContainer.withValues(alpha: 0.2),
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
                      style: style ?? KotobaTypography.bodyMd.copyWith(color: c.onSurface),
                      onSubmitted: onSubmitted,
                      decoration: InputDecoration(
                        hintText: placeholder,
                        hintStyle: (style ?? KotobaTypography.bodyMd).copyWith(
                          color: c.onSurfaceVariant.withValues(alpha: 0.5),
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

  Widget _buildSettingsCard(KotobaColors c) {
    return _glassCard(
      c,
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
                    color: c.primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  color: c.outlineVariant.withValues(alpha: 0.3),
                  height: 1,
                ),
              ],
            ),
          ),

          // Mature content toggle
          _buildToggleRow(
            c,
            title: 'Contenido Adulto',
            subtitle: 'Contiene escenas explícitas o violencia',
            value: isMature,
            activeColor: const Color(0xFFE07A5F),
            onChanged: (v) => setState(() => isMature = v),
          ),

          Divider(
            color: c.outlineVariant.withValues(alpha: 0.1),
            height: 1,
          ),

          // Completed story toggle
          _buildToggleRow(
            c,
            title: 'Historia Finalizada',
            subtitle: 'Marca la obra como completa',
            value: isCompleted,
            activeColor: c.primaryContainer,
            onChanged: (v) => setState(() => isCompleted = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    KotobaColors c, {
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
                Text(title, style: KotobaTypography.bodyMd.copyWith(color: c.onSurface)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: KotobaTypography.labelSm.copyWith(
                    color: c.onSurfaceVariant,
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
            inactiveThumbColor: c.onSurface,
            inactiveTrackColor: c.surfaceHighest,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  // ── Genres Card ─────────────────────────────────────────────────────

  static const _availableGenres = [
    'Ciencia Ficción', 'Fantasía', 'Ciberpunk', 'Fantasía Oscura',
    'Thriller', 'Misterio', 'Romance', 'Horror', 'Drama', 'Poesía',
  ];

  Widget _buildGenresCard(KotobaColors c) {
    return _glassCard(
      c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GÉNEROS',
                style: KotobaTypography.labelSm.copyWith(
                  color: c.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona de 1 a 3 géneros',
                style: KotobaTypography.labelXs.copyWith(
                  color: c.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                color: c.outlineVariant.withValues(alpha: 0.3),
                height: 1,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableGenres.map((genre) {
              final selected = _selectedGenres.contains(genre);
              final canSelect = !selected && _selectedGenres.length >= 3;
              return GestureDetector(
                onTap: canSelect
                    ? null
                    : () {
                        setState(() {
                          if (selected) {
                            _selectedGenres.remove(genre);
                          } else {
                            _selectedGenres.add(genre);
                          }
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? c.primaryContainer : c.surfaceHighest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? c.primaryContainer
                          : c.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    genre,
                    style: KotobaTypography.labelSm.copyWith(
                      color: selected ? c.background : c.onSurface,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedGenres.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Debes seleccionar al menos 1 género',
                style: KotobaTypography.labelXs.copyWith(
                  color: c.error ?? const Color(0xFFE07A5F),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Tags Card ──────────────────────────────────────────────────────

  Widget _buildTagsCard(KotobaColors c) {
    final tagInputCtrl = TextEditingController();

    return _glassCard(
      c,
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
                  color: c.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                color: c.outlineVariant.withValues(alpha: 0.3),
                height: 1,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tag input
          _buildStyledInput(
            c,
            controller: tagInputCtrl,
            placeholder: 'Añadir etiqueta y presionar enter...',
            style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
            prefixIcon: Icon(
              Icons.sell_outlined,
              size: 20,
              color: c.onSurfaceVariant,
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
                    color: c.surfaceHighest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: c.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: KotobaTypography.labelSm.copyWith(
                          color: c.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: c.onSurfaceVariant,
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

  Widget _buildTableOfContentsCard(KotobaColors c) {
    return _glassCard(
      c,
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
                  color: c.primary,
                  letterSpacing: 2,
                  height: 1.4,
                ),
              ),
              Text(
                '${_chapters.length} Capítulo${_chapters.length == 1 ? '' : 's'}',
                style: KotobaTypography.labelSm.copyWith(
                  color: c.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: c.outlineVariant.withValues(alpha: 0.3),
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
                    color: c.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...List.generate(_chapters.length, (index) {
              final ch = _chapters[index];
              return _buildChapterItem(c, ch, index + 1);
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
                  color: c.outlineVariant,
                  style: BorderStyle.solid,
                ),
                color: c.surfaceLowest.withValues(alpha: 0.5),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 28,
                    color: c.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agregar Capítulo',
                    style: KotobaTypography.labelMd.copyWith(
                      color: c.onSurfaceVariant,
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

  Widget _buildChapterItem(KotobaColors c, Chapter chapter, int number) {
    final isPublished = chapter.status == 'published';
    return InkWell(
      onTap: () => _onEditChapter(chapter),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: c.surface,
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
                color: c.surfaceLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                number.toString().padLeft(2, '0'),
                style: KotobaTypography.headlineMd.copyWith(
                  color: c.onSurfaceVariant.withValues(alpha: 0.8),
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
                    style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
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
                          ? c.onSurfaceVariant
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
              color: c.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────

  Widget _buildBottomBar(KotobaColors c) {
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
            color: c.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: c.outlineVariant.withValues(alpha: 0.1),
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
                      color: c.onSurface,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.onSurface,
                    side: BorderSide(color: c.outline),
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
                          ? c.onSurfaceVariant
                          : c.background,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: !_canPublish
                        ? c.surfaceHigh
                        : c.primaryContainer,
                    foregroundColor: !_canPublish
                        ? c.onSurfaceVariant
                        : c.background,
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
