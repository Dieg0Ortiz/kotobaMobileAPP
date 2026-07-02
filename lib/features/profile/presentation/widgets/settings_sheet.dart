import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Modal con opciones de configuración (tema, notificaciones, cerrar sesión).
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text('Ajustes', style: KotobaTypography.headlineMd),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Tema'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto)),
              ],
              selected: {ref.watch(themeModeProvider)},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title:
                Text('Notificaciones Push', style: KotobaTypography.labelMd),
            trailing: Switch(
              value: false,
              onChanged: (v) {},
              activeThumbColor: AppColors.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text('Editar Perfil', style: KotobaTypography.labelMd),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile/edit');
            },
          ),
          const Divider(color: AppColors.outlineVariant),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text('Cerrar sesión',
                style: KotobaTypography.labelMd
                    .copyWith(color: AppColors.error)),
            onTap: () {
              ref.read(logoutUseCaseProvider).execute();
              ref.read(authStateProvider.notifier).state = false;
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
        ),
      ),
    );
  }
}
