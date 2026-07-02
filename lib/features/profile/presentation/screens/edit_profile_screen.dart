import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../auth/domain/entities/user.dart';
import '../providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  bool _saving = false;

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
            SnackBar(content: Text(isBanner ? 'Imagen de fondo actualizada' : 'Foto de perfil actualizada')),
          );
        },
      );
    }
  }

  Future<void> _updateProfileField(Map<String, dynamic> data) async {
    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);

    final result = await repo.updateProfile(data);

    setState(() => _saving = false);

    if (mounted) {
      result.fold(
        (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
        (_) {
          ref.invalidate(currentProfileProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
          if (context.canPop()) context.pop(); // Close sheet
        },
      );
    }
  }

  void _showEditSheet({
    required String title,
    required String initialValue,
    required String fieldKey,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final ctrl = TextEditingController(text: initialValue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Editar $title', style: KotobaTypography.headlineMd),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: maxLines,
                keyboardType: keyboardType,
                style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceLow,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (fieldKey.startsWith('social_links.')) {
                      final key = fieldKey.split('.')[1];
                      _updateProfileField({'social_links': {key: ctrl.text.trim()}});
                    } else {
                      _updateProfileField({fieldKey: ctrl.text.trim()});
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(DateTime? initialDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime(2004, 6, 3),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final isoDate = picked.toIso8601String().split('T').first;
      _updateProfileField({'birth_date': isoDate});
    }
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        title,
        style: KotobaTypography.labelMd.copyWith(
          color: isDestructive ? AppColors.error : AppColors.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: KotobaTypography.bodyMd.copyWith(
                color: isDestructive ? AppColors.error.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title, {String? description}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: KotobaTypography.headlineMd),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: KotobaTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil & cuenta', style: KotobaTypography.headlineMd),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: Stack(
        children: [
          profileAsync.when(
            loading: () => const Center(child: KotobaLoading()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (user) {
              return ListView(
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  _buildSectionHeader(
                    'Perfil',
                    description: 'La información que introduzcas aquí será visible a otros usuarios. Aprende más sobre compartir información de manera segura aquí.',
                  ),
                  _buildListTile(
                    title: 'Foto de perfil',
                    subtitle: 'Pulsa aquí para cambiarla',
                    trailing: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.surfaceLow,
                      backgroundImage: user.avatarUrl != null ? CachedNetworkImageProvider(user.avatarUrl!) : null,
                      child: user.avatarUrl == null ? const Icon(Icons.person, color: AppColors.onSurfaceVariant) : null,
                    ),
                    onTap: () => _pickImage(false),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Imagen de fondo',
                    subtitle: 'Pulsa aquí para cambiarla',
                    trailing: Container(
                      width: 80,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(4),
                        image: user.bannerUrl != null
                            ? DecorationImage(image: CachedNetworkImageProvider(user.bannerUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: user.bannerUrl == null ? const Icon(Icons.wallpaper, color: AppColors.onSurfaceVariant) : null,
                    ),
                    onTap: () => _pickImage(true),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Info',
                    subtitle: user.bio?.isNotEmpty == true ? user.bio : 'Añadir información',
                    onTap: () => _showEditSheet(title: 'Info', initialValue: user.bio ?? '', fieldKey: 'bio', maxLines: 4),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Nombre de usuario',
                    subtitle: user.username,
                    onTap: () => _showEditSheet(title: 'Nombre de usuario', initialValue: user.username, fieldKey: 'username'),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Nombre Completo',
                    subtitle: user.fullName?.isNotEmpty == true ? user.fullName : 'Añadir nombre',
                    onTap: () => _showEditSheet(title: 'Nombre Completo', initialValue: user.fullName ?? '', fieldKey: 'full_name'),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Pronombres',
                    subtitle: user.pronouns?.isNotEmpty == true ? user.pronouns : 'Añadir pronombres',
                    onTap: () => _showEditSheet(title: 'Pronombres', initialValue: user.pronouns ?? '', fieldKey: 'pronouns'),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Ubicación',
                    subtitle: user.country?.isNotEmpty == true ? user.country : 'Añadir ubicación',
                    onTap: () => _showEditSheet(title: 'Ubicación', initialValue: user.country ?? '', fieldKey: 'country'),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Sitio web',
                    subtitle: user.socialLinks?['website']?.isNotEmpty == true ? user.socialLinks!['website'] : 'Configura un sitio web',
                    onTap: () => _showEditSheet(title: 'Sitio web', initialValue: user.socialLinks?['website'] ?? '', fieldKey: 'social_links.website', keyboardType: TextInputType.url),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 32),
                  
                  _buildSectionHeader('Redes Sociales'),
                  _buildListTile(
                    title: 'Google',
                    subtitle: 'Desvincula Diego Ortiz', // Mock
                    trailing: Checkbox(value: true, onChanged: (v) {}, activeColor: AppColors.primary),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Facebook',
                    subtitle: 'Vincular tu cuenta de Facebook', // Mock
                    trailing: Checkbox(value: false, onChanged: (v) {}, activeColor: AppColors.primary),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 32),

                  _buildSectionHeader(
                    'Configuración de la Cuenta',
                    description: 'La información que introduzcas aquí no será visible para otros usuarios.',
                  ),
                  _buildListTile(
                    title: 'Correo electrónico',
                    subtitle: user.email,
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Contraseña',
                    subtitle: '********',
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: '¿Olvidaste tu contraseña?',
                    onTap: () {},
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Fecha de nacimiento',
                    subtitle: user.birthDate != null ? DateFormat('MMM d, yyyy').format(user.birthDate!) : 'Añadir fecha',
                    onTap: () => _selectDate(user.birthDate),
                  ),
                  const Divider(color: AppColors.surfaceLow, height: 1, indent: 24, endIndent: 24),
                  _buildListTile(
                    title: 'Cerrar Cuenta',
                    subtitle: 'Visita el sitio web para cerrar tu cuenta',
                    isDestructive: true,
                  ),
                ],
              );
            },
          ),
          if (_saving)
            Container(
              color: Colors.black54,
              child: const Center(child: KotobaLoading()),
            ),
        ],
      ),
    );
  }
}
