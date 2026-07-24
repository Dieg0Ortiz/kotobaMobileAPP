import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/reader/presentation/providers/reader_providers.dart';

// ── Provider que guarda y cambia el tema (light/dark/system) ───
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

// ── Notifier que cambia el tema y lo guarda en SharedPreferences ─
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'app_theme_mode';

  ThemeModeNotifier(this._prefs) : super(_loadThemeMode(_prefs));

  // Carga el tema guardado o usa system por defecto
  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final savedMode = prefs.getString(_key);
    if (savedMode == 'light') return ThemeMode.light;
    if (savedMode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  // Cambia el tema y lo persiste
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _prefs.setString(_key, mode.name);

  }

  // Alterna entre claro y oscuro
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}
