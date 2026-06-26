import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema Material 3 de Kotoba — "Ink & Silence".
///
/// Kotoba es dark-only por diseño. No existe [lightTheme] en el MVP.
/// El modo de lectura puede ofrecer un fondo sepia como variante, no blanco.
class KotobaTheme {
  KotobaTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          tertiary: AppColors.action,
          onTertiary: AppColors.onAction,
          tertiaryContainer: AppColors.actionContainer,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          surfaceContainerLowest: AppColors.surfaceLowest,
          surfaceContainerLow: AppColors.surfaceLow,
          surfaceContainer: AppColors.surface,
          surfaceContainerHigh: AppColors.surfaceHigh,
          surfaceContainerHighest: AppColors.surfaceHighest,
        ),

        // AppBar: transparente, sin elevación, fondo del scaffold
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Noto Serif JP',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          iconTheme: IconThemeData(color: AppColors.onSurface),
        ),

        // Cards: superficie oscura con borde sutil
        cardTheme: CardThemeData(
          color: AppColors.surfaceLow,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: AppColors.onSurface.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),

        // NavigationRail (tablet/desktop)
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: AppColors.surfaceLowest,
          selectedIconTheme: IconThemeData(color: AppColors.primary),
          unselectedIconTheme:
              IconThemeData(color: AppColors.onSurfaceVariant),
          selectedLabelTextStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
          unselectedLabelTextStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
          indicatorColor: Colors.transparent,
        ),

        // BottomNavigationBar (móvil)
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceLowest,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Input Fields: oscuros con borde gris, focus en gold
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide:
                const BorderSide(color: AppColors.outline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide:
                const BorderSide(color: AppColors.outline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
                color: AppColors.primaryContainer, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1),
          ),
          hintStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: AppColors.outline,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),

        // Chips: para géneros, tags y filtros
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceHigh,
          selectedColor: AppColors.primaryFixed,
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
          side: const BorderSide(
              color: AppColors.outlineVariant, width: 1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.outlineVariant,
          thickness: 1,
          space: 0,
        ),

        // IconTheme base
        iconTheme: const IconThemeData(
            color: AppColors.onSurfaceVariant, size: 20),
      );
}
