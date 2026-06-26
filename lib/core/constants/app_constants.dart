/// Constantes de configuración de la aplicación.
class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    const defineUrl = String.fromEnvironment('API_URL', defaultValue: '');
    if (defineUrl.isNotEmpty) return defineUrl;
    return 'https://kotoba-back-production.up.railway.app/api';
  }
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ── Endpoints ───────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String users = '/users';
  static const String works = '/works';
  static const String chapters = '/chapters';
  static const String comments = '/comments';
  static const String uploadCover = '/upload/cover';

  static String userById(String id) => '$users/$id';
  static String userStats(String authorId) => '$users/$authorId/stats';
  static String workById(String id) => '$works/$id';
  static String chapterById(String id) => '$chapters/$id';
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
