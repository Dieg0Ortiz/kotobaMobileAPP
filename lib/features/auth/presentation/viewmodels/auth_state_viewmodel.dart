import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthStateViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoggedIn(bool value) {
    state = value;
  }

  void logout() {
    state = false;
  }
}

