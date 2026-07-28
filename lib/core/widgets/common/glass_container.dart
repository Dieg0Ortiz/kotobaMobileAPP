import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../theme/liquid_glass.dart';
import '../../theme/kotoba_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final LiquidGlassConfig? config;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final BorderRadius? borderRadiusGeometry;
  final bool showRefraction;
  final bool showHighlight;
  final bool showBorderGlow;
  final bool clipContent;
  final VoidCallback? onTap;
  final Decoration? foregroundDecoration;

  const GlassContainer({
    required this.child,
    this.config,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderRadiusGeometry,
    this.showRefraction = true,
    this.showHighlight = true,
    this.showBorderGlow = true,
    this.clipContent = true,
    this.onTap,
    this.foregroundDecoration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = config ?? LiquidGlassConfig.frosted;
    final c = KotobaColors.of(context);
    final radius = borderRadius ?? cfg.borderRadius;
    final borderR = borderRadiusGeometry ?? BorderRadius.circular(radius);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderR,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: cfg.blurSigma,
            sigmaY: cfg.blurSigma,
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: c.surface.withValues(alpha: cfg.backgroundOpacity),
                borderRadius: borderR,
                border: Border.all(
                  color: c.onSurface.withValues(
                    alpha: cfg.borderGlowOpacity,
                  ),
                  width: 0.5,
                ),
              ),
              foregroundDecoration: _buildForeground(cfg, c, borderR),
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Decoration? _buildForeground(
    LiquidGlassConfig cfg,
    KotobaColors c,
    BorderRadius borderR,
  ) {
    final highlights = <BoxShadow>[];
    final gradients = <Gradient>[];

    if (showHighlight) {
      gradients.add(
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.onSurface.withValues(alpha: cfg.highlightOpacity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4],
        ),
      );
    }

    if (showBorderGlow) {
      highlights.add(
        BoxShadow(
          color: c.onSurface.withValues(alpha: cfg.borderGlowOpacity * 0.3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      );
    }

    if (gradients.isEmpty && highlights.isEmpty) return null;

    return BoxDecoration(
      borderRadius: borderR,
      gradient: gradients.isNotEmpty ? gradients.first : null,
      boxShadow: highlights.isNotEmpty ? highlights : null,
    );
  }
}
