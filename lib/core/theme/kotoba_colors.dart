import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Helper que resuelve colores según el tema activo (light / dark).
///
/// Uso: `final c = KotobaColors.of(context);`
/// Después: `c.background`, `c.primary`, `c.onSurface`, etc.
///
/// Mantiene los mismos nombres semánticos que [AppColors] y [AppColorsLight],
/// seleccionando automáticamente la paleta correcta.
class KotobaColors {
  final Brightness _brightness;
  const KotobaColors._(this._brightness);

  /// Crea una instancia que resuelve colores según el brillo del tema actual.
  static KotobaColors of(BuildContext context) {
    return KotobaColors._(Theme.of(context).brightness);
  }

  bool get isDark => _brightness == Brightness.dark;

  // ── Fondos ──────────────────────────────────────────────────────────
  Color get background =>
      isDark ? AppColors.background : AppColorsLight.background;
  Color get surfaceLowest =>
      isDark ? AppColors.surfaceLowest : AppColorsLight.surfaceLowest;
  Color get surfaceLow =>
      isDark ? AppColors.surfaceLow : AppColorsLight.surfaceLow;
  Color get surface => isDark ? AppColors.surface : AppColorsLight.surface;
  Color get surfaceHigh =>
      isDark ? AppColors.surfaceHigh : AppColorsLight.surfaceHigh;
  Color get surfaceHighest =>
      isDark ? AppColors.surfaceHighest : AppColorsLight.surfaceHighest;
  Color get surfaceBright =>
      isDark ? AppColors.surfaceBright : AppColorsLight.surfaceBright;

  // ── Texto ───────────────────────────────────────────────────────────
  Color get onSurface =>
      isDark ? AppColors.onSurface : AppColorsLight.onSurface;
  Color get onSurfaceVariant =>
      isDark ? AppColors.onSurfaceVariant : AppColorsLight.onSurfaceVariant;
  Color get outline => isDark ? AppColors.outline : AppColorsLight.outline;
  Color get outlineVariant =>
      isDark ? AppColors.outlineVariant : AppColorsLight.outlineVariant;

  // ── Primario: Amber Gold ────────────────────────────────────────────
  Color get primary => isDark ? AppColors.primary : AppColorsLight.primary;
  Color get primaryDim =>
      isDark ? AppColors.primaryDim : AppColorsLight.primaryDim;
  Color get primaryContainer =>
      isDark ? AppColors.primaryContainer : AppColorsLight.primaryContainer;
  Color get onPrimary =>
      isDark ? AppColors.onPrimary : AppColorsLight.onPrimary;
  Color get primaryFixed =>
      isDark ? AppColors.primaryFixed : AppColorsLight.primaryFixed;

  // ── Secundario ──────────────────────────────────────────────────────
  Color get secondary =>
      isDark ? AppColors.secondary : AppColorsLight.secondary;
  Color get secondaryContainer =>
      isDark ? AppColors.secondaryContainer : AppColorsLight.secondaryContainer;
  Color get onSecondary =>
      isDark ? AppColors.onSecondary : AppColorsLight.onSecondary;

  // ── Terciario / Acción ──────────────────────────────────────────────
  Color get action => isDark ? AppColors.action : AppColorsLight.action;
  Color get actionContainer =>
      isDark ? AppColors.actionContainer : AppColorsLight.actionContainer;
  Color get onAction => isDark ? AppColors.onAction : AppColorsLight.onAction;

  // ── Error ───────────────────────────────────────────────────────────
  Color get error => isDark ? AppColors.error : AppColorsLight.error;
  Color get errorContainer =>
      isDark ? AppColors.errorContainer : AppColorsLight.errorContainer;
  Color get onError => isDark ? AppColors.onError : AppColorsLight.onError;
}
