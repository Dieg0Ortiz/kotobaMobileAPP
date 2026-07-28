import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../theme/liquid_glass.dart';
import '../../theme/kotoba_colors.dart';

class GlassBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final Widget? leading;
  final Widget? trailing;

  const GlassBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.leading,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    const cfg = LiquidGlassConfig.bar;

    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: cfg.blurSigma,
          sigmaY: cfg.blurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: cfg.backgroundOpacity),
            border: Border(
              top: BorderSide(
                color: c.onSurface.withValues(alpha: cfg.borderGlowOpacity),
                width: 0.5,
              ),
            ),
          ),
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                c.onSurface.withValues(alpha: cfg.highlightOpacity),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom > 0 ? 4 : 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (leading != null) leading!,
                  for (int i = 0; i < items.length; i++)
                    _NavItem(
                      item: items[i],
                      isSelected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final BottomNavigationBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    final color = isSelected ? c.primary : c.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? c.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? (item.activeIcon is Icon
                      ? (item.activeIcon as Icon).icon
                      : item.icon is Icon
                          ? (item.icon as Icon).icon
                          : Icons.circle)
                  : item.icon is Icon
                      ? (item.icon as Icon).icon
                      : Icons.circle,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              item.label ?? '',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
