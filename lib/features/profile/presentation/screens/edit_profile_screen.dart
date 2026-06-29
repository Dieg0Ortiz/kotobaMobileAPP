import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _bioCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.uploadAvatar(bytes, file.name);
    setState(() => _saving = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) {
        ref.invalidate(currentProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      },
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateProfile({
      'bio': _bioCtrl.text.trim(),
    });
    setState(() => _saving = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) {
        ref.invalidate(currentProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado')),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Guardar'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(Icons.person, size: 48, color: AppColors.onSurfaceVariant)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 18, color: AppColors.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _pickAvatar,
                child: const Text('Cambiar foto de perfil'),
              ),
            ),
            const SizedBox(height: 24),
            Text('Nombre de usuario', style: KotobaTypography.labelMd),
            const SizedBox(height: 8),
            Text(user.username, style: KotobaTypography.bodyLg),
            const SizedBox(height: 24),
            Text('Biografía', style: KotobaTypography.labelMd),
            const SizedBox(height: 8),
            TextField(
              controller: _bioCtrl..text = user.bio ?? '',
              maxLines: 4,
              style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Escribe algo sobre ti...',
                filled: true,
                fillColor: AppColors.surfaceLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
