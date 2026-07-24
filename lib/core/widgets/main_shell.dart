import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/kotoba_colors.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';

/// Shell con BottomNavigationBar para las pestañas principales.
///
/// Envuelve las rutas dentro del ShellRoute de GoRouter.
class MainShell extends ConsumerWidget {
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
    if (location.startsWith('/profile') || location.startsWith('/dashboard')) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);
    final c = KotobaColors.of(context);
    final unreadAsync = ref.watch(unreadCountProvider);
    final unreadCount = unreadAsync.whenOrNull(data: (count) => count) ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          // ── Desktop / Tablet Layout (Left Sidebar) ──
          return Scaffold(
            body: Row(
              children: [
                // Sidebar
                Container(
                  width: 250,
                  color: c.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kotoba',
                              style: TextStyle(
                                fontFamily: 'Noto Serif JP',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: c.primary,
                              ),
                            ),
                            Text(
                              'LITERARY CINEMA',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                                color: c.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      _SidebarItem(
                        icon: Icons.home_outlined,
                        label: 'HOME',
                        isSelected: currentIndex == 0,
                        onTap: () => context.go('/home'),
                      ),
                      _SidebarItem(
                        icon: Icons.search,
                        label: 'SEARCH',
                        isSelected: currentIndex == 1,
                        onTap: () => context.go('/search'),
                      ),
                      _SidebarItem(
                        icon: Icons.menu_book_outlined,
                        label: 'LIBRARY',
                        isSelected: currentIndex == 3,
                        onTap: () => context.go('/library'),
                      ),
                      _SidebarItem(
                        icon: Icons.person_outline,
                        label: 'PROFILE',
                        isSelected: currentIndex == 4,
                        onTap: () => context.go('/profile'),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/write'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD9735A), // Terracotta
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text('WRITE NOW', style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content with top border divider if needed
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: c.outlineVariant.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          );
        }

        // ── Mobile Layout (Bottom Nav Bar) ──
        return Scaffold(
          body: Stack(
            children: [
              child,
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: c.surface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.notifications_outlined, color: c.onSurface, size: 22),
                        if (unreadCount > 0)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9735A),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? c.outlineVariant.withValues(alpha: 0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? c.primary : c.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                letterSpacing: 1,
                color: isSelected ? c.onSurface : c.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
