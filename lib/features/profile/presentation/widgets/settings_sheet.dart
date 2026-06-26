import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajustes', style: KotobaTypography.headlineMd),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text('Modo Oscuro (Fijo en MVP)',
                style: KotobaTypography.labelMd),
            trailing: Switch(
              value: true,
              onChanged: null,
              activeThumbColor: AppColors.primary,
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
          const Divider(color: AppColors.outlineVariant),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text('Cerrar sesión',
                style: KotobaTypography.labelMd
                    .copyWith(color: AppColors.error)),
            onTap: () {
              ref.read(logoutUseCaseProvider).execute();
              ref.read(authStateProvider.notifier).logout();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
