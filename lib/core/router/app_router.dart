import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/search_screen.dart';
import '../../features/profile/presentation/screens/author_dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reader/presentation/screens/chapter_reader_screen.dart';
import '../../features/reader/presentation/screens/work_detail_screen.dart';
import '../../features/write/presentation/screens/edit_story_screen.dart';
import '../../features/write/presentation/screens/my_stories_screen.dart';
import '../../features/write/presentation/screens/write_dashboard_screen.dart';
import '../widgets/main_shell.dart';

/// Router declarativo con GoRouter.
///
/// El guard usa [mockAuthStateProvider] para simular autenticación.
/// 🔄 BACKEND INTEGRATION: reemplazar mockAuthStateProvider por
/// un provider real basado en JWT/SecureStorage.
final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(mockAuthStateProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: '/works/:workId',
            builder: (_, state) => WorkDetailScreen(
              workId: state.pathParameters['workId']!,
            ),
            routes: [
              GoRoute(
                path: 'chapters/:chapterId',
                builder: (_, state) => ChapterReaderScreen(
                  chapterId: state.pathParameters['chapterId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/write',
            builder: (_, __) => const WriteDashboardScreen(),
            routes: [
              GoRoute(
                path: 'stories',
                builder: (_, __) => const MyStoriesScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (_, state) => EditStoryScreen(
                  storyId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/author/dashboard',
            builder: (_, __) => const AuthorDashboardScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Estado de autenticación mock.
///
/// `true` = usuario logueado (para prototipar la app completa).
/// Cambiar a `false` para ver el flujo de auth.
///
/// 🔄 BACKEND INTEGRATION: eliminar este provider y usar el real
/// basado en JWT almacenado en SecureStorage.
final mockAuthStateProvider = StateProvider<bool>((ref) => true);
