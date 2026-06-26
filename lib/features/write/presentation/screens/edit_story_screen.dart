import 'dart:io';

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
import '../../../../core/widgets/common/kotoba_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../reader/data/repositories/content_repository_impl.dart';
import '../../../reader/domain/entities/chapter.dart';

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

  String? _actualWorkId;
  bool get _isNew => _actualWorkId == null;

  @override
  void initState() {
    super.initState();
    if (widget.storyId == 'new') {
      _actualWorkId = null;
      _loading = false;
    } else {
      _actualWorkId = widget.storyId;
      _loadWork();
    }
  }

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

  Future<bool> _saveStory({bool replaceRoute = false}) async {
    final title = _titleCtrl.text.trim().isEmpty ? 'Historia sin título' : _titleCtrl.text.trim();
    setState(() => _saving = true);
    final repo = ref.read(workRepositoryProvider);
    final body = {
      'title': title,
      'synopsis': _synopsisCtrl.text.trim(),
      'tags': _tagsCtrl.text.trim().split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      'genre': 'Sin género',
      'status': isCompleted ? 'completed' : 'draft',
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isNew ? 'Historia creada' : 'Guardado')));
        }
        if (!_isNew) _loadChapters();
        return true;
      },
    );
  }

  Future<void> _onNewChapter() async {
    if (_isNew) {
      final saved = await _saveStory(replaceRoute: true);
      if (!saved) return;
    }
    if (!mounted) return;
    context.go('/write/edit/$_actualWorkId/chapter/new');
  }

  void _onEditChapter(Chapter ch) {
    context.go('/write/edit/$_actualWorkId/chapter/${ch.id}');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Text(_isNew ? 'Crear Historia' : 'Editar Historia', style: KotobaTypography.headlineMd),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: KotobaButton(
              label: _isNew ? 'Crear' : 'Guardar Cambios',
              onPressed: _saving ? null : () => _saveStory(replaceRoute: true),
              isLoading: _saving,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Portada
          _sectionTitle('Portada'),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: _localCoverFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(_localCoverFile!.path, fit: BoxFit.cover, width: double.infinity)
                          : Image.file(File(_localCoverFile!.path), fit: BoxFit.cover, width: double.infinity),
                    )
                  : _coverUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(imageUrl: _coverUrl!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : const Center(child: Icon(Icons.add_photo_alternate, size: 48, color: AppColors.onSurfaceVariant)),
            ),
          ),
          const SizedBox(height: 8),
          Text('Toca para seleccionar una imagen de portada', style: KotobaTypography.labelXs),

          // Info
          const SizedBox(height: 24),
          _sectionTitle('Título *'),
          _textField(ctrl: _titleCtrl),
          _sectionTitle('Descripción *'),
          _textField(ctrl: _synopsisCtrl, maxLines: 3),
          _sectionTitle('Etiquetas'),
          _textField(ctrl: _tagsCtrl, hint: 'Ej: romance, fantasía...'),
          _switchTile(title: 'Madura', subtitle: 'Contenido para público maduro.', value: isMature, onChanged: (v) => setState(() => isMature = v)),
          _switchTile(title: 'Historia Completa', subtitle: 'Marca si la historia ya está terminada.', value: isCompleted, onChanged: (v) => setState(() => isCompleted = v)),

          const SizedBox(height: 32),
          const Divider(),
          // Tabla de contenido
          Row(
            children: [
              Text('TABLA DE CONTENIDO', style: KotobaTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo capítulo'),
                onPressed: _onNewChapter,
              ),
            ],
          ),
          if (_chapters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Aún no hay capítulos. Toca "Nuevo capítulo" para empezar.',
                    style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ),
            )
          else
            ..._chapters.map((ch) => _ChapterTile(
                  chapter: ch,
                  onTap: () => _onEditChapter(ch),
                )),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(title, style: KotobaTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _textField({required TextEditingController ctrl, int maxLines = 1, String? hint}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: KotobaTypography.bodyMd,
      decoration: InputDecoration(
        hintText: hint,
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outlineVariant)),
      ),
    );
  }

  Widget _switchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KotobaTypography.bodyLg),
                const SizedBox(height: 4),
                Text(subtitle, style: KotobaTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.action),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const _ChapterTile({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPublished = chapter.status == 'published';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isPublished ? AppColors.actionContainer : AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('${chapter.number}', style: KotobaTypography.labelSm)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapter.title, style: KotobaTypography.bodyLg),
                  Text(isPublished ? 'Publicado' : 'Borrador',
                      style: KotobaTypography.labelXs.copyWith(
                          color: isPublished ? AppColors.action : AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
