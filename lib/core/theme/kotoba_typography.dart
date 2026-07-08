import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema tipográfico triple de Kotoba "Ink & Silence".
///
/// Tres familias con roles distintos:
/// - **Noto Serif JP**: títulos hero, nombre de la plataforma, pull quotes,
///   estadísticas del dashboard.
/// - **Source Serif 4** (Dinámica): cuerpo de capítulos, sinopsis, lectura prolongada.
/// - **DM Sans**: botones, navegación, etiquetas, metadatos, chips, badges.
///
/// Los colores NO se definen aquí — se heredan del [DefaultTextStyle] del tema
/// o se pasan explícitamente con `.copyWith(color: ...)`.
class KotobaTypography {
  KotobaTypography._();

  static String readerFontFamily = 'Source Serif 4';

  // ── DISPLAY: Noto Serif JP ────────────────────────────────────────

  /// Título hero (e.g., "Kotoba 言葉" en Home).
  /// Mobile: 40px (desktop: 72px).
  static const displayXL = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.01,
  );

  /// Titulares de sección, nombre de obra en detalle.
  static const headlineLg = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Sub-titulares, "Sinopsis", "Índice".
  static const headlineMd = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  /// Pull quote: Noto Serif JP italic en gold.
  /// Nota: el color primario se debe pasar con `.copyWith(color: c.primary)`.
  static const pullQuote = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.6,
  );

  /// Número grande de estadística (Dashboard: "2,847", "48,320").
  static const statNumber = TextStyle(
    fontFamily: 'Noto Serif JP',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  // ── READING: Dinámica ──────────────────────────────────────────────

  /// Cuerpo de capítulo principal. Optimizado para lectura prolongada.
  static TextStyle get bodyLg => GoogleFonts.getFont(
    readerFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.78,
  );

  /// Sinopsis, descripciones largas.
  static TextStyle get bodyMd => GoogleFonts.getFont(
    readerFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.625,
  );

  // ── UI: DM Sans ───────────────────────────────────────────────────

  /// Botones, navegación, etiquetas de tamaño medio.
  static const labelMd = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.05,
  );

  /// Autor en cards, metadatos secundarios.
  static const labelSm = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: 0.1,
  );

  /// Timestamps, contadores mínimos.
  static const labelXs = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.08,
  );

  /// Etiqueta de género en caps (e.g., "SCI-FI", "FANTASÍA").
  static const genreLabel = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
  );
}
