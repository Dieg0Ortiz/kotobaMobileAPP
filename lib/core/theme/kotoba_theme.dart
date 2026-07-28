import 'package:flutter/material.dart';

import 'app_colors.dart';

// ── Tema oscuro y claro de la app (Material 3) ────────────────
class KotobaTheme {
  KotobaTheme._();

  // ── Tema oscuro ────────────────────────────────────────────────
  static ThemeData get darkTheme => _buildDarkTheme(isIOS: false);

  static ThemeData get darkThemeIOS => _buildDarkTheme(isIOS: true);

  static ThemeData _buildDarkTheme({required bool isIOS}) => ThemeData(
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
        appBarTheme: AppBarTheme(
          backgroundColor: isIOS
              ? AppColors.surface.withValues(alpha: 0.7)
              : AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Noto Serif JP',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isIOS
                ? AppColors.primary.withValues(alpha: 0.95)
                : AppColors.primary,
          ),
          iconTheme: IconThemeData(
            color: isIOS
                ? AppColors.onSurface.withValues(alpha: 0.9)
                : AppColors.onSurface,
          ),
        ),

        // Cards: superficie oscura con borde sutil
        cardTheme: CardThemeData(
          color: isIOS
              ? AppColors.surface.withValues(alpha: 0.55)
              : AppColors.surfaceLow,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.onSurface.withValues(
                alpha: isIOS ? 0.08 : 0.05,
              ),
              width: 0.5,
            ),
          ),
          clipBehavior: isIOS ? Clip.antiAlias : Clip.none,
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

        // Dialog (glass on iOS, solid elsewhere)
        dialogTheme: DialogThemeData(
          backgroundColor: isIOS
              ? AppColors.surface.withValues(alpha: 0.75)
              : AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // BottomSheet (glass on iOS)
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: isIOS
              ? AppColors.surface.withValues(alpha: 0.75)
              : AppColors.surface,
          surfaceTintColor: Colors.transparent,
          modalBackgroundColor: isIOS
              ? AppColors.surface.withValues(alpha: 0.75)
              : AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),

        // IconTheme base
        iconTheme: IconThemeData(
          color: isIOS
              ? AppColors.onSurface.withValues(alpha: 0.85)
              : AppColors.onSurfaceVariant,
          size: 20,
        ),
      );

  // ── Tema claro ───────────────────────────────────────────────
  static ThemeData get lightTheme => _buildLightTheme(isIOS: false);

  static ThemeData get lightThemeIOS => _buildLightTheme(isIOS: true);

  static ThemeData _buildLightTheme({required bool isIOS}) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColorsLight.background,

        colorScheme: const ColorScheme.light(
          surface: AppColorsLight.surface,
          onSurface: AppColorsLight.onSurface,
          onSurfaceVariant: AppColorsLight.onSurfaceVariant,
          primary: AppColorsLight.primary,
          onPrimary: AppColorsLight.onPrimary,
          primaryContainer: AppColorsLight.primaryContainer,
          secondary: AppColorsLight.secondary,
          onSecondary: AppColorsLight.onSecondary,
          secondaryContainer: AppColorsLight.secondaryContainer,
          tertiary: AppColorsLight.action,
          onTertiary: AppColorsLight.onAction,
          tertiaryContainer: AppColorsLight.actionContainer,
          error: AppColorsLight.error,
          onError: AppColorsLight.onError,
          errorContainer: AppColorsLight.errorContainer,
          outline: AppColorsLight.outline,
          outlineVariant: AppColorsLight.outlineVariant,
          surfaceContainerLowest: AppColorsLight.surfaceLowest,
          surfaceContainerLow: AppColorsLight.surfaceLow,
          surfaceContainer: AppColorsLight.surface,
          surfaceContainerHigh: AppColorsLight.surfaceHigh,
          surfaceContainerHighest: AppColorsLight.surfaceHighest,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: isIOS
              ? AppColorsLight.surface.withValues(alpha: 0.7)
              : AppColorsLight.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Noto Serif JP',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isIOS
                ? AppColorsLight.primary.withValues(alpha: 0.95)
                : AppColorsLight.primary,
          ),
          iconTheme: IconThemeData(
            color: isIOS
                ? AppColorsLight.onSurface.withValues(alpha: 0.9)
                : AppColorsLight.onSurface,
          ),
        ),

        cardTheme: CardThemeData(
          color: isIOS
              ? AppColorsLight.surface.withValues(alpha: 0.5)
              : AppColorsLight.surfaceLowest,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColorsLight.onSurface.withValues(
                alpha: isIOS ? 0.12 : 0.1,
              ),
              width: 0.5,
            ),
          ),
          clipBehavior: isIOS ? Clip.antiAlias : Clip.none,
        ),

        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: AppColorsLight.surfaceLowest,
          selectedIconTheme: IconThemeData(color: AppColorsLight.primary),
          unselectedIconTheme: IconThemeData(color: AppColorsLight.onSurfaceVariant),
          selectedLabelTextStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColorsLight.primary,
          ),
          unselectedLabelTextStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: AppColorsLight.onSurfaceVariant,
          ),
          indicatorColor: Colors.transparent,
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColorsLight.surfaceLowest,
          selectedItemColor: AppColorsLight.primary,
          unselectedItemColor: AppColorsLight.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColorsLight.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColorsLight.outline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColorsLight.outline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColorsLight.primaryContainer, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColorsLight.error, width: 1),
          ),
          hintStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: AppColorsLight.outline,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: AppColorsLight.onSurfaceVariant,
          ),
        ),

        chipTheme: ChipThemeData(
          backgroundColor: AppColorsLight.surfaceHigh,
          selectedColor: AppColorsLight.primaryFixed,
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColorsLight.onSurface,
          ),
          side: const BorderSide(color: AppColorsLight.outlineVariant, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        dividerTheme: const DividerThemeData(
          color: AppColorsLight.outlineVariant,
          thickness: 1,
          space: 0,
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: isIOS
              ? AppColorsLight.surface.withValues(alpha: 0.75)
              : AppColorsLight.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: isIOS
              ? AppColorsLight.surface.withValues(alpha: 0.75)
              : AppColorsLight.surface,
          surfaceTintColor: Colors.transparent,
          modalBackgroundColor: isIOS
              ? AppColorsLight.surface.withValues(alpha: 0.75)
              : AppColorsLight.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),

        iconTheme: IconThemeData(
          color: isIOS
              ? AppColorsLight.onSurface.withValues(alpha: 0.85)
              : AppColorsLight.onSurfaceVariant,
          size: 20,
        ),
      );
}
