import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/providers/auth_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/kotoba_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/reader/presentation/providers/reader_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: DevicePreview(
        enabled: false,
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
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Kotoba',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      theme: KotobaTheme.lightTheme,
      darkTheme: KotobaTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
