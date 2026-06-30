import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/secure_storage_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/kotoba_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/reader/presentation/providers/reader_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = SecureStorageService();
  final isLoggedIn = await storage.hasTokens();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authStateProvider.overrideWith((ref) => isLoggedIn),
      ],
      child: const KotobaApp(),
    ),
  );
}

/// Widget raíz de la aplicación Kotoba.
class KotobaApp extends ConsumerWidget {
  const KotobaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Kotoba',

      theme: KotobaTheme.lightTheme,
      darkTheme: KotobaTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
