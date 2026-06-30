import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/register_viewmodel.dart';

// ── Infraestructura ──────────────────────────────────────────────
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage);
});

// ── Repositorio ──────────────────────────────────────────────────
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final api = ref.read(apiClientProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepositoryImpl(api, storage);
});

// ── Use Cases ────────────────────────────────────────────────────
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(repository: ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(repository: ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(repository: ref.read(authRepositoryProvider));
});

// ── ViewModels ───────────────────────────────────────────────────
final loginViewModelProvider =
    AsyncNotifierProvider<LoginViewModel, void>(LoginViewModel.new);

final registerViewModelProvider =
    AsyncNotifierProvider<RegisterViewModel, void>(RegisterViewModel.new);



/// Estado global de autenticación.
/// Se inicializa con la sesión actual de Supabase y se mantiene sincronizado
/// escuchando [onAuthStateChange]. También sincroniza los tokens con
/// [SecureStorageService] para que el [ApiClient] siempre tenga un token válido.
final authStateProvider = StateProvider<bool>((ref) {
  final auth = Supabase.instance.client.auth;

  // Sincronizar sesión inicial al arrancar la app
  final currentSession = auth.currentSession;
  if (currentSession != null) {
    _syncTokens(currentSession);
  }

  ref.onDispose(auth.onAuthStateChange.listen((data) {
    final session = data.session;

    if (session != null) {
      _syncTokens(session);
      // Fire-and-forget: asegura que el usuario exista en public.users
      _syncDiscordUser();
    }

    ref.controller.state = session != null;
  }).cancel);

  return currentSession != null;
});

/// Guarda los tokens en SecureStorage para que el ApiClient pueda usarlos.
void _syncTokens(Session session) {
  final storage = SecureStorageService();
  storage.saveTokens(
    accessToken: session.accessToken,
    refreshToken: session.refreshToken ?? '',
  );
}

/// Llama al backend para asegurar que el usuario de Discord existe en la tabla
/// `public.users`. Es un fire-and-forget porque el trigger `handle_new_user()`
/// ya debió crearlo automáticamente — este es solo un safety net.
Future<void> _syncDiscordUser() async {
  try {
    final storage = SecureStorageService();
    final api = ApiClient(storage);
    (await api.post('/auth/discord', data: {})).fold((_) => null, (_) => null);
  } catch (_) {
    // Non-fatal
  }
}
