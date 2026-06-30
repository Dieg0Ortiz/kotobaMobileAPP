import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _bioCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _xCtrl = TextEditingController();
  final _igCtrl = TextEditingController();
  final _webCtrl = TextEditingController();
  
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _bioCtrl.dispose();
    _ageCtrl.dispose();
    _countryCtrl.dispose();
    _xCtrl.dispose();
    _igCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  void _initControllers(dynamic user) {
    if (_initialized) return;
    _bioCtrl.text = user.bio ?? '';
    _ageCtrl.text = user.age?.toString() ?? '';
    _countryCtrl.text = user.country ?? '';
    _xCtrl.text = user.socialLinks?['x'] ?? '';
    _igCtrl.text = user.socialLinks?['instagram'] ?? '';
    _webCtrl.text = user.socialLinks?['website'] ?? '';
    // Use addPostFrameCallback to avoid set state during build issues just in case, though this is synchronous
    _initialized = true;
  }

  Future<void> _pickImage(bool isBanner) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery, 
      maxWidth: isBanner ? 1024 : 512, 
      maxHeight: isBanner ? 512 : 512,
    );
    if (file == null) return;
    
    final bytes = await file.readAsBytes();
    setState(() => _saving = true);
    
    final repo = ref.read(profileRepositoryProvider);
    final result = isBanner 
        ? await repo.uploadBanner(bytes, file.name)
        : await repo.uploadAvatar(bytes, file.name);
        
    setState(() => _saving = false);
    
    if (mounted) {
      result.fold(
        (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
        (_) {
          ref.invalidate(currentProfileProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isBanner ? 'Banner actualizado' : 'Foto de perfil actualizada')),
          );
        },
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    
    final socialLinks = {
      if (_xCtrl.text.trim().isNotEmpty) 'x': _xCtrl.text.trim(),
      if (_igCtrl.text.trim().isNotEmpty) 'instagram': _igCtrl.text.trim(),
      if (_webCtrl.text.trim().isNotEmpty) 'website': _webCtrl.text.trim(),
    };

    final result = await repo.updateProfile({
      'bio': _bioCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()),
      'country': _countryCtrl.text.trim(),
      'social_links': socialLinks.isNotEmpty ? socialLinks : null,
    });
    
    setState(() => _saving = false);
    
    if (mounted) {
      result.fold(
        (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
        (_) {
          ref.invalidate(currentProfileProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
          if (context.canPop()) context.pop();
        },
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KotobaTypography.labelMd),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant.withAlpha(128)),
            filled: true,
            fillColor: AppColors.surfaceLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () { if (context.canPop()) context.pop(); },
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
        data: (user) {
          _initControllers(user);
          
          return ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              // Banner y Avatar Stack
              SizedBox(
                height: 220,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Banner
                    GestureDetector(
                      onTap: () => _pickImage(true),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow,
                          image: user.bannerUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(user.bannerUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user.bannerUrl == null
                            ? const Center(
                                child: Icon(Icons.wallpaper, size: 48, color: AppColors.onSurfaceVariant),
                              )
                            : null,
                      ),
                    ),
                    // Edit Banner Icon
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => _pickImage(true),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(153),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    // Avatar
                    Positioned(
                      bottom: 0,
                      left: 24,
                      child: GestureDetector(
                        onTap: () => _pickImage(false),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.surfaceLow,
                                backgroundImage: user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: user.avatarUrl == null
                                    ? const Icon(Icons.person, size: 48, color: AppColors.onSurfaceVariant)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.surface, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: AppColors.onPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre de usuario', style: KotobaTypography.labelMd),
                    const SizedBox(height: 8),
                    Text(user.username, style: KotobaTypography.bodyLg),
                    const SizedBox(height: 32),
                    
                    _buildTextField(
                      label: 'Biografía',
                      controller: _bioCtrl,
                      hintText: 'Escribe algo sobre ti...',
                      maxLines: 4,
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildTextField(
                            label: 'Edad',
                            controller: _ageCtrl,
                            hintText: 'Ej. 25',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            label: 'País / Ubicación',
                            controller: _countryCtrl,
                            hintText: 'Ej. México',
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(color: AppColors.surfaceLow, height: 48),
                    Text('Redes Sociales', style: KotobaTypography.headlineMd),
                    const SizedBox(height: 24),
                    
                    _buildTextField(
                      label: 'X (Twitter)',
                      controller: _xCtrl,
                      hintText: 'https://x.com/usuario',
                      keyboardType: TextInputType.url,
                    ),
                    
                    _buildTextField(
                      label: 'Instagram',
                      controller: _igCtrl,
                      hintText: 'https://instagram.com/usuario',
                      keyboardType: TextInputType.url,
                    ),
                    
                    _buildTextField(
                      label: 'Sitio Web',
                      controller: _webCtrl,
                      hintText: 'https://mi-portafolio.com',
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
