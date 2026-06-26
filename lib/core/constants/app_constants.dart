/// Constantes de configuración de la aplicación.
class ApiConstants {
  ApiConstants._();

  // 🔄 BACKEND INTEGRATION: cambiar a la URL real del servidor
  // static const String baseUrl = 'https://api.kotoba.app/v1';
  static const String baseUrl = 'http://localhost:3000/api'; // No usado en esta fase
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

/// Constantes generales de la app.
class AppConstants {
  AppConstants._();

  static const String appName = 'Kotoba';
  static const String appNameJp = '言葉';
  static const String appTagline =
      'Tu historia, sin límites. Sumérgete en narrativas cinemáticas y descubre voces que transforman el vacío en universos.';
  static const String appVersion = '1.0.0';
  static const int paginationLimit = 20;
  static const int maxRecentBooks = 10;
  static const Duration mockNetworkDelay = Duration(milliseconds: 700);
  static const Duration mockShortDelay = Duration(milliseconds: 400);
}
