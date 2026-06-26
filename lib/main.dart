import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/kotoba_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 🔄 BACKEND INTEGRATION: inicializar aquí:
  // await Hive.initFlutter();
  // await HiveAdapters.registerAll();
  runApp(
    const ProviderScope(
      child: KotobaApp(),
    ),
  );
}

/// Widget raíz de la aplicación Kotoba.
///
/// Dark-only: no existe lightTheme en esta app.
/// Usa MaterialApp.router con GoRouter para navegación declarativa.
class KotobaApp extends ConsumerWidget {
  const KotobaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Kotoba',
      theme: KotobaTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
