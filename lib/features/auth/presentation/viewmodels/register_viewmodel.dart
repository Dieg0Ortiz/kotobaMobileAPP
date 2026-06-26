import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/register_usecase.dart';
import '../providers/auth_providers.dart';

class RegisterViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  String _email = '';
  String _password = '';
  String _username = '';
  int? _age;
  String _country = '';

  void updateEmail(String email) => _email = email;
  void updatePassword(String password) => _password = password;
  void updateUsername(String username) => _username = username;
  void updateAge(String age) => _age = int.tryParse(age);
  void updateCountry(String country) => _country = country;

  Future<void> submit() async {
    if (_email.isEmpty || _password.isEmpty || _username.isEmpty) {
      state = AsyncError('Por favor completa todos los campos', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    final usecase = ref.read(registerUseCaseProvider);
    final result = await usecase.execute(
      RegisterParams(
        email: _email,
        password: _password,
        username: _username,
        age: _age,
        country: _country.isNotEmpty ? _country : null,
      ),
    );

    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) {
        ref.read(authStateProvider.notifier).setLoggedIn(true);
        return const AsyncData(null);
      },
    );
  }
}
