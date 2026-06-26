import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado global de autenticación.
///
/// En esta fase es un simple bool. Al conectar el backend,
/// se reemplaza por un ViewModel que observe JWT en SecureStorage.
class AuthStateViewModel extends Notifier<bool> {
  @override
  bool build() => true; // Mock: usuario logueado por defecto

  void setLoggedIn(bool value) {
    state = value;
  }

  void logout() {
    state = false;
  }
}
