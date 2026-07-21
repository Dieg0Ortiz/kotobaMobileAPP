import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/reader_providers.dart';

// ── Modo de lectura ──────────────────────────────────────────────
enum ReadingMode { cascade, page }

class ReaderPreferences {
  final double fontSize;
  final String fontFamily;
  final ReadingMode readingMode;

  const ReaderPreferences({
    this.fontSize = 18.0,
    this.fontFamily = 'Source Serif 4',
    this.readingMode = ReadingMode.cascade,
  });

  ReaderPreferences copyWith({
    double? fontSize,
    String? fontFamily,
    ReadingMode? readingMode,
  }) {
    return ReaderPreferences(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      readingMode: readingMode ?? this.readingMode,
    );
  }
}

class ReaderPreferencesViewModel extends Notifier<ReaderPreferences> {
  late SharedPreferences _prefs;

  @override
  ReaderPreferences build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final size = _prefs.getDouble('reader_fontSize') ?? 18.0;
    final family = _prefs.getString('reader_fontFamily') ?? 'Source Serif 4';
    final mode = _prefs.getString('reader_readingMode') ?? 'cascade';
    return ReaderPreferences(
      fontSize: size,
      fontFamily: family,
      readingMode: mode == 'page' ? ReadingMode.page : ReadingMode.cascade,
    );
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size);
    _prefs.setDouble('reader_fontSize', size);
  }

  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
    _prefs.setString('reader_fontFamily', family);
  }

  void setReadingMode(ReadingMode mode) {
    state = state.copyWith(readingMode: mode);
    _prefs.setString('reader_readingMode', mode == ReadingMode.page ? 'page' : 'cascade');
  }
}
