/// Constantes de configuración de la aplicación.
class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    const defineUrl = String.fromEnvironment('API_URL', defaultValue: '');
    if (defineUrl.isNotEmpty) return defineUrl;
    return 'https://kotoba-back-production.up.railway.app/api';
  }

  /// URL base para el Content Microservice.
  /// Se puede sobrescribir con --dart-define=CONTENT_API_URL=...
  static String get contentBaseUrl {
    const defineUrl = String.fromEnvironment('CONTENT_API_URL', defaultValue: '');
    if (defineUrl.isNotEmpty) return defineUrl;
    // Si no hay define, apunta al monolith (misma URL que baseUrl)
    return 'https://kotoba-back-production.up.railway.app/api';
  }

  /// URL base para el Payment Microservice.
  /// Se puede sobrescribir con --dart-define=PAYMENT_API_URL=...
  static String get paymentBaseUrl {
    const defineUrl = String.fromEnvironment('PAYMENT_API_URL', defaultValue: '');
    if (defineUrl.isNotEmpty) return defineUrl;
    return 'https://kotobapay-production.up.railway.app/api';
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
  static const String bookmarks = '/bookmarks';
  static const String uploadCover = '/upload/cover';
  static const String search = '/search';

  static String userById(String id) => '$users/$id';
  static String userStats(String authorId) => '$users/$authorId/stats';
  static const String followingAuthors = '$users/me/following-authors';
  static const String newAuthors = '$users/new-authors';
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
