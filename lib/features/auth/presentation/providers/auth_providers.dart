import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/register_viewmodel.dart';

// ── Guarda tokens en el dispositivo ─────────────────────────────
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// ── Cliente HTTP para el backend principal ──────────────────────
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage);
});

// ── Cliente HTTP para el Content Microservice ───────────────────
final contentApiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage, baseUrl: ApiConstants.contentBaseUrl);
});

// ── Cliente HTTP para el Payment Microservice ───────────────────
final paymentApiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage, baseUrl: ApiConstants.paymentBaseUrl);
});

// ── Cliente HTTP para Social (likes compartidos con el backend principal) ──
final socialApiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage, baseUrl: ApiConstants.baseUrl);
});

// ── Repositorio de autenticación (login, register, logout) ──────
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final api = ref.read(apiClientProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepositoryImpl(api, storage);
});

// ── Casos de uso (orquestan la lógica de negocio) ───────────────
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(repository: ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(repository: ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(repository: ref.read(authRepositoryProvider));
});

// ── ViewModels (estado + acciones para las pantallas) ───────────
final loginViewModelProvider =
    AsyncNotifierProvider<LoginViewModel, void>(LoginViewModel.new);

final registerViewModelProvider =
    AsyncNotifierProvider<RegisterViewModel, void>(RegisterViewModel.new);

const _inactiveDaysLimit = 30;
const _lastActiveKey = 'last_active_timestamp';

// ── ¿Hay sesión? true/false. Se actualiza solo con Supabase ────
final authStateProvider = StateProvider<bool>((ref) {
  final auth = Supabase.instance.client.auth;

  // Check stored session synchronously (may be null on first call)
  final currentSession = auth.currentSession;
  if (currentSession != null) {
    _syncTokens(currentSession);
    _updateActiveTimestamp();
  }

  // Listen to auth changes (fires on session restore, login, logout)
  ref.onDispose(auth.onAuthStateChange.listen((data) {
    final session = data.session;

    if (session != null) {
      _syncTokens(session);
      _syncOAuthUser();
      _updateActiveTimestamp();
      ref.invalidate(needsProfileCompletionProvider);
    }

    ref.controller.state = session != null;
  }).cancel);

  return currentSession != null;
});

/// Provider que inicializa la sesión (recupera sesión guardada y chequea inactividad).
/// Usar este provider para esperar a que la sesión esté lista.
final authInitProvider = FutureProvider<void>((ref) async {
  final auth = Supabase.instance.client.auth;

  // Check 30-day inactivity
  final prefs = await SharedPreferences.getInstance();
  final lastActive = prefs.getInt(_lastActiveKey);
  if (lastActive != null) {
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastActive;
    final limitMs = _inactiveDaysLimit * 24 * 60 * 60 * 1000;
    if (elapsed > limitMs) {
      try {
        await auth.signOut();
      } catch (_) {}
      await prefs.remove(_lastActiveKey);
      ref.invalidate(authStateProvider);
      return;
    }
  }

  // Update auth state provider with the current session
  ref.invalidate(authStateProvider);
});

Future<void> _updateActiveTimestamp() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
}

/// Guarda la marca de actividad del usuario (se llama desde la app al abrir/interactuar)
Future<void> updateLastActivity() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
}

// ── Guarda accessToken y refreshToken en el dispositivo ─────────
void _syncTokens(Session session) {
  final storage = SecureStorageService();
  storage.saveTokens(
    accessToken: session.accessToken,
    refreshToken: session.refreshToken ?? '',
  );
}

// ── Safety net: asegura que el usuario OAuth exista en la BD ────
Future<void> _syncOAuthUser() async {
  try {
    final storage = SecureStorageService();
    final api = ApiClient(storage);
    (await api.post('/auth/discord', data: {})).fold((_) => null, (_) => null);
  } catch (_) {}
}

/// Provider que indica si el usuario OAuth necesita completar su perfil
final userProfileCompleteProvider = StateProvider<bool>((ref) => false);

/// Verifica si el usuario actual tiene username completo
final needsProfileCompletionProvider = FutureProvider<bool>((ref) async {
  final auth = Supabase.instance.client.auth;
  final user = auth.currentUser;
  if (user == null) return false;

  try {
    final storage = SecureStorageService();
    final api = ApiClient(storage);
    final result = await api.get<Map<String, dynamic>>('/users/me');
    return result.fold(
      (_) => false,
      (data) {
        final username = data['username'] as String?;
        final needsComplete = username == null || username.startsWith('user_');
        ref.read(userProfileCompleteProvider.notifier).state = !needsComplete;
        return needsComplete;
      },
    );
  } catch (_) {
    return false;
  }
});
