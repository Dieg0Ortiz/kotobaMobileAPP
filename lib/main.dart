import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';

import 'core/router/app_router.dart';
import 'core/theme/kotoba_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const KotobaApp(),
      ),
    ),
  );
}

/// Widget raíz de la aplicación Kotoba.
class KotobaApp extends ConsumerWidget {
  const KotobaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Kotoba',
      // Estas líneas son para Device Preview:
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      theme: KotobaTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
