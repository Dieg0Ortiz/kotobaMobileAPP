import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

const _inactiveDaysLimit = 30;
const _lastActiveKey = 'last_active_timestamp';

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

  // Espera a que Supabase recupere la sesión guardada y chequea inactividad
  await _initSession();

  final prefs = await SharedPreferences.getInstance();

  await Hive.initFlutter();
  await DownloadService.init();

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    try {
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
    } catch (e) {
      print('Error obtaining FCM token at startup: $e');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      print('FCM Token refreshed: $fcmToken');
    }).onError((err) {
      print('Error refreshing FCM token: $err');
    });
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const KotobaApp(),
    ),
  );
}

Future<void> _initSession() async {
  final auth = Supabase.instance.client.auth;

  // Si la sesión aún no se ha recuperado, esperamos el primer evento
  if (auth.currentSession == null) {
    await auth.onAuthStateChange.first;
  }

  final session = auth.currentSession;
  if (session == null) return;

  // Check 30-day inactivity
  final prefs = await SharedPreferences.getInstance();
  final lastActive = prefs.getInt(_lastActiveKey);
  if (lastActive != null) {
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastActive;
    final limitMs = _inactiveDaysLimit * 24 * 60 * 60 * 1000;
    if (elapsed > limitMs) {
      await auth.signOut();
      await prefs.remove(_lastActiveKey);
      return;
    }
  }

  await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
}

// ── Widget raíz de la app ──────────────────────────────────────
class KotobaApp extends ConsumerWidget {
  const KotobaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Kotoba',

      // Tema claro y oscuro (con Liquid Glass en iOS)
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? KotobaTheme.lightThemeIOS
          : KotobaTheme.lightTheme,
      darkTheme: defaultTargetPlatform == TargetPlatform.iOS
          ? KotobaTheme.darkThemeIOS
          : KotobaTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
