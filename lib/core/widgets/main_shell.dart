import 'package:flutter/material.dart';

import '../theme/kotoba_colors.dart';
import 'package:go_router/go_router.dart';

/// Shell con BottomNavigationBar para las pestañas principales.
///
/// Envuelve las rutas dentro del ShellRoute de GoRouter.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({required this.child, super.key});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/search')) {
      return 1;
    }
    if (location.startsWith('/write')) {
      return 2;
    }
    if (location.startsWith('/profile') || location.startsWith('/author')) {
      return 4;
    }
    if (location.startsWith('/library')) {
      return 3;
    }
    if (location.startsWith('/works')) {
      return 0; // detail from home
    }
    return 0; // /home
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final c = KotobaColors.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: c.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/home');
              case 1:
                context.go('/search');
              case 2:
                context.go('/write');
              case 3:
                context.go('/library');
              case 4:
                context.go('/profile');
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_outlined),
              activeIcon: Icon(Icons.edit),
              label: 'Escribir',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Biblioteca',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
