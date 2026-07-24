import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Modal con opciones de configuración (tema, notificaciones, cerrar sesión).
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KotobaColors.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text('Ajustes', style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
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
                Text('Notificaciones Push', style: KotobaTypography.labelMd.copyWith(color: c.onSurface)),
            trailing: Switch(
              value: false,
              onChanged: (v) {},
              activeThumbColor: c.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: Text('Copiar Token FCM', style: KotobaTypography.labelMd.copyWith(color: c.onSurface)),
            subtitle: Text('Token de prueba para Firebase', style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant)),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final token = await FirebaseMessaging.instance.getToken();
                if (token != null) {
                  await Clipboard.setData(ClipboardData(text: token));
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Token FCM copiado: ${token.substring(0, 20)}...'),
                      backgroundColor: c.primary,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('No se pudo obtener el token de FCM')),
                  );
                }
              } catch (e) {
                if (defaultTargetPlatform == TargetPlatform.iOS) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('iOS requiere cuenta de Apple Developer paga para Notificaciones APNs Push en dispositivo físico.'),
                      duration: Duration(seconds: 5),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error al obtener token: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text('Editar Perfil', style: KotobaTypography.labelMd.copyWith(color: c.onSurface)),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile/edit');
            },
          ),
          Divider(color: c.outlineVariant),
          ListTile(
            leading: Icon(Icons.logout, color: c.error),
            title: Text('Cerrar sesión',
                style: KotobaTypography.labelMd
                    .copyWith(color: c.error)),
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
