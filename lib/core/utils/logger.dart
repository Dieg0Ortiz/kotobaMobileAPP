import 'package:flutter/foundation.dart';

/// Logger centralizado de la aplicación.
///
/// Principio SRP: única responsabilidad de registrar eventos.
/// Principio OCP: extensible para agregar analytics, Crashlytics, etc.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      print('🐛 [${tag ?? 'DEBUG'}] $message');
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      print('ℹ️ [${tag ?? 'INFO'}] $message');
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      print('⚠️ [${tag ?? 'WARNING'}] $message');
    }
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('❌ [${tag ?? 'ERROR'}] $message');
      if (error != null) print('   Error: $error');
      if (stackTrace != null) print('   StackTrace: $stackTrace');
    }
    // TODO: Enviar a Crashlytics/Firebase en producción.
  }
}
