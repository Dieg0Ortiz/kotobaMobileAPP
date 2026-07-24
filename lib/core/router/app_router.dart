import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/search_screen.dart';
import '../../features/profile/presentation/screens/author_dashboard_screen.dart';
import '../../features/profile/presentation/screens/author_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reader/presentation/screens/chapter_reader_screen.dart';
import '../../features/reader/presentation/screens/work_detail_screen.dart';
import '../../features/write/presentation/screens/chapter_editor_screen.dart';
import '../../features/write/presentation/screens/edit_story_screen.dart';
import '../../features/write/presentation/screens/my_stories_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/write/presentation/screens/write_dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../widgets/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
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
      GoRoute(
        path: '/users/:userId',
        builder: (_, state) => AuthorProfileScreen(
          userId: state.pathParameters['userId']!,
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
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
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) => ChapterReaderScreen(
                  chapterId: state.pathParameters['chapterId']!,
                  workId: state.pathParameters['workId'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const EditProfileScreen(),
              ),
            ],
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
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) => EditStoryScreen(
                  storyId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'edit/:id/chapter/:chapterId',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) => ChapterEditorScreen(
                  workId: state.pathParameters['id']!,
                  chapterId: state.pathParameters['chapterId']! == 'new' ? null : state.pathParameters['chapterId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/library',
            builder: (_, __) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const AuthorDashboardScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
  );
});
