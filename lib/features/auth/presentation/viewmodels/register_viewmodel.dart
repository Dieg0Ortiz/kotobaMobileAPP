import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ViewModel del registro.
class RegisterViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  String _email = '';
  String _password = '';
  String _username = '';

  void updateEmail(String email) => _email = email;
  void updatePassword(String password) => _password = password;
  void updateUsername(String username) => _username = username;

  Future<void> submit() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!_email.contains('@') || _password.length < 6 || _username.isEmpty) {
        throw Exception('Por favor completa todos los campos correctamente');
      }
    });
  }
}
