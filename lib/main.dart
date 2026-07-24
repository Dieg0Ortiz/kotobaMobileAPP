import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/kotoba_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/download_service.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/reader/presentation/providers/reader_providers.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  final prefs = await SharedPreferences.getInstance();

  await Hive.initFlutter();
  await DownloadService.init();

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final settings = await FirebaseMessaging.instance.requestPermission(
      provisional: true,
    );
    print('Notification permission: ${settings.authorizationStatus}');

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        print('FCM Token: $fcmToken');
      }
    } else {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $fcmToken');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      print('FCM Token refreshed: $fcmToken');
    }).onError((err) {
      print('Error refreshing FCM token: $err');
    });
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (_) => ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const KotobaApp(),
      ),
    ),
  );
}

// ── Widget raíz de la app ──────────────────────────────────────
class KotobaApp extends ConsumerWidget {
  const KotobaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auth session and check inactivity
    ref.watch(authInitProvider);
    // Update last activity timestamp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateLastActivity();
    });

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Kotoba',

      // Tema claro y oscuro
      theme: KotobaTheme.lightTheme,
      darkTheme: KotobaTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
