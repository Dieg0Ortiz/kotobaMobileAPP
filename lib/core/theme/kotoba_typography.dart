import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sistema tipográfico triple de Kotoba "Ink & Silence".
///
/// Tres familias con roles distintos:
/// - **Noto Serif JP**: títulos hero, nombre de la plataforma, pull quotes,
///   estadísticas del dashboard.
/// - **Source Serif 4**: cuerpo de capítulos, sinopsis, lectura prolongada.
/// - **DM Sans**: botones, navegación, etiquetas, metadatos, chips, badges.
///
/// Todas las fuentes se cargan vía [google_fonts] en el MVP.
class KotobaTypography {
  KotobaTypography._();

  // ── DISPLAY: Noto Serif JP ────────────────────────────────────────

  /// Título hero (e.g., "Kotoba 言葉" en Home).
  /// Mobile: 40px (desktop: 72px).
  static const displayXL = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.01,
    color: AppColors.onSurface,
  );

  /// Titulares de sección, nombre de obra en detalle.
  static const headlineLg = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.onSurface,
  );

  /// Sub-titulares, "Sinopsis", "Índice".
  static const headlineMd = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.onSurface,
  );

  /// Pull quote: Noto Serif JP italic en gold.
  static const pullQuote = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.6,
    color: AppColors.primary,
  );

  /// Número grande de estadística (Dashboard: "2,847", "48,320").
  static const statNumber = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.onSurface,
  );

  // ── READING: Source Serif 4 ──────────────────────────────────────

  /// Cuerpo de capítulo principal. Optimizado para lectura prolongada.
  static const bodyLg = TextStyle(
    fontFamily: 'Source Serif 4',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.78,
    color: AppColors.onSurface,
  );

  /// Sinopsis, descripciones largas.
  static const bodyMd = TextStyle(
    fontFamily: 'Source Serif 4',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.625,
    color: AppColors.onSurface,
  );

  // ── UI: DM Sans ───────────────────────────────────────────────────

  /// Botones, navegación, etiquetas de tamaño medio.
  static const labelMd = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.05,
    color: AppColors.onSurface,
  );

  /// Autor en cards, metadatos secundarios.
  static const labelSm = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: 0.1,
    color: AppColors.onSurfaceVariant,
  );

  /// Timestamps, contadores mínimos.
  static const labelXs = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.08,
    color: AppColors.onSurfaceVariant,
  );

  /// Etiqueta de género en caps (e.g., "SCI-FI", "FANTASÍA").
  static const genreLabel = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    color: AppColors.onSurfaceVariant,
  );
}
