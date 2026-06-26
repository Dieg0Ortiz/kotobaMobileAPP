import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  ReaderPreferences build() => const ReaderPreferences();

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size);
  }

  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
  }
}
