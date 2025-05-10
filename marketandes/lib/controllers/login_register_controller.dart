import 'package:flutter/material.dart';

class LoginRegisterController {
  void goToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  void goToRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  void goToOfflineUsers(BuildContext context) {
    Navigator.pushNamed(context, '/offlineLogin');
  }
}
