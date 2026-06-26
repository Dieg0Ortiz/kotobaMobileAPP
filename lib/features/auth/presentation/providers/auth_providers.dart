import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_auth_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../viewmodels/auth_state_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/register_viewmodel.dart';

// ── Repositorio ──────────────────────────────────────────────────
// 🔄 BACKEND INTEGRATION: reemplazar MockAuthRepository por AuthRepositoryImpl
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return MockAuthRepository();
});

// ── Use Cases ────────────────────────────────────────────────────
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(repository: ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(repository: ref.read(authRepositoryProvider));
});

// ── ViewModels ───────────────────────────────────────────────────
final loginViewModelProvider =
    AsyncNotifierProvider<LoginViewModel, void>(LoginViewModel.new);

final registerViewModelProvider =
    AsyncNotifierProvider<RegisterViewModel, void>(RegisterViewModel.new);

final authStateProvider =
    NotifierProvider<AuthStateViewModel, bool>(AuthStateViewModel.new);
