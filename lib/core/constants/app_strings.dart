/// Strings de UI centralizados — i18n-ready.
///
/// Cuando se implemente internacionalización, este archivo
/// se reemplaza por archivos .arb y el paquete intl.
class AppStrings {
  AppStrings._();

  // ── Auth ────────────────────────────────────────────────────────
  static const loginTitle = 'Iniciar sesión';
  static const registerTitle = 'Crear cuenta';
  static const emailLabel = 'Correo electrónico';
  static const passwordLabel = 'Contraseña';
  static const usernameLabel = 'Nombre de usuario';
  static const loginButton = 'INICIAR SESIÓN';
  static const registerButton = 'CREAR CUENTA';
  static const forgotPassword = '¿Olvidaste tu contraseña?';
  static const noAccount = '¿No tienes cuenta?';
  static const hasAccount = '¿Ya tienes cuenta?';
  static const orContinueWith = 'O continúa con';
  static const continueWithGoogle = 'Continuar con Google';
  static const continueWithDiscord = 'Continuar con Discord';

  // ── Navigation ──────────────────────────────────────────────────
  static const navHome = 'Inicio';
  static const navSearch = 'Buscar';
  static const navLibrary = 'Biblioteca';
  static const navProfile = 'Perfil';

  // ── Home / Catalog ──────────────────────────────────────────────
  static const trending = 'Tendencias';
  static const seeAll = 'Ver todas →';
  static const selectionForYou = 'Selección Para Ti';
  static const mainRecommendation = 'RECOMENDACIÓN PRINCIPAL';
  static const startReading = 'COMENZAR A LEER';
  static const newAuthors = 'Nuevos Autores';
  static const exploreWorks = 'EXPLORAR OBRAS';
  static const publish = 'PUBLICAR';

  // ── Search ──────────────────────────────────────────────────────
  static const searchHint = 'Buscar obras, autores, géneros...';
  static const filters = 'Filtros';
  static const loadMore = 'CARGAR MÁS OBRAS';
  static const noResults = 'No se encontraron resultados';

  // ── Work Detail ─────────────────────────────────────────────────
  static const synopsis = 'Sinopsis';
  static const readMore = 'LEER MÁS';
  static const chapterIndex = 'Índice';
  static const chapters = 'CAPÍTULOS';
  static const supportAuthor = 'APOYAR AL AUTOR';
  static const seeAllChapters = 'VER TODOS LOS CAPÍTULOS';
  static const reviews = 'Reseñas';
  static const seeAllReviews = 'LEER TODAS LAS RESEÑAS →';

  // ── Reader ──────────────────────────────────────────────────────
  static const fontSettings = 'Ajustes de lectura';
  static const fontSize = 'Tamaño de fuente';
  static const fontFamily = 'Tipografía';
  static const nextChapter = 'Siguiente capítulo';
  static const previousChapter = 'Capítulo anterior';
  static const endOfChapter = 'FIN DEL CAPÍTULO';

  // ── Profile ─────────────────────────────────────────────────────
  static const followers = 'Seguidores';
  static const works = 'Obras';
  static const totalReads = 'Lecturas';
  static const follow = 'SEGUIR';
  static const tabWorks = 'Obras';
  static const tabAbout = 'Sobre mí';
  static const tabActivity = 'Actividad';
  static const tabLists = 'Listas';
  static const achievements = 'LOGROS';
  static const genres = 'GÉNEROS';
  static const recentActivity = 'ACTIVIDAD RECIENTE';
  static const similarAuthors = 'AUTORES SIMILARES';

  // ── Dashboard ───────────────────────────────────────────────────
  static const authorDashboard = 'Panel de Autor';
  static const activeReaders = 'Lectores activos';
  static const engagement = 'Engagement';
  static const nextPublication = 'Próxima publicación';
  static const newChapter = '+ NUEVO CAPÍTULO';

  // ── Genres ──────────────────────────────────────────────────────
  static const genreSciFi = 'Ciencia Ficción';
  static const genreFantasy = 'Fantasía';
  static const genreThriller = 'Thriller';
  static const genreCyberpunk = 'Ciberpunk';
  static const genreDarkFantasy = 'Fantasía Oscura';
  static const genreMystery = 'Misterio';
  static const genreRomance = 'Romance';
  static const genreHorror = 'Horror';

  // ── Status ──────────────────────────────────────────────────────
  static const statusOngoing = 'En Progreso';
  static const statusCompleted = 'Completada';
  static const statusHiatus = 'En Pausa';

  // ── Errors ──────────────────────────────────────────────────────
  static const errorGeneric = 'Ha ocurrido un error';
  static const errorNetwork = 'Sin conexión a internet';
  static const errorRetry = 'REINTENTAR';
}
