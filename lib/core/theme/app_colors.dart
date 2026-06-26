import 'package:flutter/material.dart';

/// Paleta de colores "Nocturnal Canvas" del sistema de diseño Ink & Silence.
///
/// Todos los colores se registran en el [ColorScheme] de Material 3
/// a través de [KotobaTheme.darkTheme].
///
/// Reglas de uso:
/// - El fondo siempre es [background]. Nunca blanco ni grises claros.
/// - [primary] (gold): decoración, énfasis tipográfico, íconos activos.
/// - [action] (terracota): SOLO para CTAs de máxima prioridad.
/// - [secondary] (indigo): badges informativos, estados secundarios.
/// - Texto corrido: [onSurface]. Metadatos: [onSurfaceVariant].
class AppColors {
  AppColors._();

  // ── Fondos (de más oscuro a más claro) ──────────────────────────
  static const background = Color(0xFF131410);
  static const surfaceLowest = Color(0xFF0E0E0B);
  static const surfaceLow = Color(0xFF1C1C18);
  static const surface = Color(0xFF20201C);
  static const surfaceHigh = Color(0xFF2A2A26);
  static const surfaceHighest = Color(0xFF353530);
  static const surfaceBright = Color(0xFF3A3935);

  // ── Texto ────────────────────────────────────────────────────────
  static const onSurface = Color(0xFFE5E2DB);
  static const onSurfaceVariant = Color(0xFFD0C5B5);
  static const outline = Color(0xFF998F81);
  static const outlineVariant = Color(0xFF4D463A);

  // ── Primario: Amber Gold ─────────────────────────────────────────
  static const primary = Color(0xFFE5C487);
  static const primaryDim = Color(0xFFE3C285);
  static const primaryContainer = Color(0xFFC8A96E);
  static const onPrimary = Color(0xFF402D00);
  static const primaryFixed = Color(0xFFFFDEA3);

  // ── Secundario: Indigo Blue ──────────────────────────────────────
  static const secondary = Color(0xFFA9C7FF);
  static const secondaryContainer = Color(0xFF25497D);
  static const onSecondary = Color(0xFF003063);

  // ── Terciario / Acción: Terracotta ──────────────────────────────
  static const action = Color(0xFFFFB8A5);
  static const actionContainer = Color(0xFFFC9074);
  static const onAction = Color(0xFF5D1805);

  // ── Error ────────────────────────────────────────────────────────
  static const error = Color(0xFFFFB4AB);
  static const errorContainer = Color(0xFF93000A);
  static const onError = Color(0xFF690005);
}
