import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ── Cliente HTTP para el Social Microservice ───────────────────
final socialApiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage, baseUrl: ApiConstants.socialBaseUrl);
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



// ── ¿Hay sesión? true/false. Se actualiza solo con Supabase ────
final authStateProvider = StateProvider<bool>((ref) {
  final auth = Supabase.instance.client.auth;

  final currentSession = auth.currentSession;
  if (currentSession != null) {
    _syncTokens(currentSession);
  }

  ref.onDispose(auth.onAuthStateChange.listen((data) {
    final session = data.session;

    if (session != null) {
      _syncTokens(session);
      _syncDiscordUser();
    }

    ref.controller.state = session != null;
  }).cancel);

  return currentSession != null;
});

// ── Guarda accessToken y refreshToken en el dispositivo ─────────
void _syncTokens(Session session) {
  final storage = SecureStorageService();
  storage.saveTokens(
    accessToken: session.accessToken,
    refreshToken: session.refreshToken ?? '',
  );
}

// ── Safety net: asegura que el usuario de Discord exista en la BD ─
Future<void> _syncDiscordUser() async {
  try {
    final storage = SecureStorageService();
    final api = ApiClient(storage);
    (await api.post('/auth/discord', data: {})).fold((_) => null, (_) => null);
  } catch (_) {}
}
