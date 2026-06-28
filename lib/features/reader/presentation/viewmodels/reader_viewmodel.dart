import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/reader_providers.dart';

class ReaderPreferences {
  final double fontSize;
  final String fontFamily;

  const ReaderPreferences({
    this.fontSize = 18.0,
    this.fontFamily = 'Source Serif 4',
  });

  ReaderPreferences copyWith({
    double? fontSize,
    String? fontFamily,
  }) {
    return ReaderPreferences(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
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
    return ReaderPreferences(fontSize: size, fontFamily: family);
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size);
    _prefs.setDouble('reader_fontSize', size);
  }

  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
    _prefs.setString('reader_fontFamily', family);
  }
}
