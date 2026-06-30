import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/usecases/login_usecase.dart';
import '../providers/auth_providers.dart';

/// Estado del formulario de login.
class LoginFormState extends Equatable {
  final String email;
  final String password;
  final bool isPasswordVisible;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

  @override
  List<Object> get props => [email, password, isPasswordVisible];
}

/// ViewModel del login.
///
/// Gestiona el estado del formulario y la operación async de login.
/// Llama al [LoginUseCase] que internamente usa el mock repository.
class LoginViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  LoginFormState _formState = const LoginFormState();
  LoginFormState get formState => _formState;

  void updateEmail(String email) {
    _formState = _formState.copyWith(email: email);
  }

  void updatePassword(String password) {
    _formState = _formState.copyWith(password: password);
  }

  void togglePasswordVisibility() {
    _formState = _formState.copyWith(
        isPasswordVisible: !_formState.isPasswordVisible);
    ref.notifyListeners();
  }

  Future<void> submit() async {
    state = const AsyncLoading();
    final usecase = ref.read(loginUseCaseProvider);
    final result = await usecase.execute(
      LoginParams(email: _formState.email, password: _formState.password),
    );
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) {
        // Update global auth state on success
        ref.read(authStateProvider.notifier).state = true;
        return const AsyncData(null);
      },
    );
  }

  Future<void> signInWithDiscord() async {
    state = const AsyncLoading();
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.discord,
        redirectTo: 'com.devshainyv.kotobaapp://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      
      // Reseteamos el estado porque el navegador se abre externamente.
      // Si hay un error al volver, lo manejaremos en onAuthStateChange,
      // pero no queremos que la app se quede con el spinner infinito.
      state = const AsyncData(null);
      
    } catch (e) {
      state = AsyncError('Error al iniciar sesión con Discord', StackTrace.current);
    }
  }
}
