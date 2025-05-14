import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketandes/controllers/auth_controller.dart';
import 'package:marketandes/controllers/session_timer_controller.dart';
import '../models/login_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoginController {
  final LoginModel model;
  final BuildContext context;

  LoginController({required this.model, required this.context});

  Future<void> login(VoidCallback onStateChanged) async {
    model.isLoading = true;
    model.errorMessage = null;
    onStateChanged();

    final email = model.emailController.text.trim();
    final password = model.passwordController.text.trim();

    try {
      if (!email.endsWith('@uniandes.edu.co')) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Usa tu correo institucional @uniandes.edu.co',
        );
      }

      final credential = await authService.value.signIn(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid ?? '';
      sessionStartTime = DateTime.now();

      // Mostrar diálogo para guardar offline
      final box = Hive.box('offlineUsers');
      final alreadySaved = box.values.any((entry) => entry['email'] == email);

      if (!alreadySaved) {
        final shouldSave = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("¿Guardar usuario para uso sin conexión?"),
                content: const Text(
                  "Esto te permitirá iniciar sesión sin internet desde este dispositivo.",
                ),
                actions: [
                  TextButton(
                    child: const Text("No"),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  ElevatedButton(
                    child: const Text("Sí, guardar"),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
        );

        if (shouldSave == true) {
          box.put(uid, {'uid': uid, 'email': email, 'password': password});
        }
      }

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'FirebaseAuthException -> code: ${e.code}, message: ${e.message}',
      );
      model.errorMessage = _firebaseErrorToMessage(e);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      model.errorMessage = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
    } finally {
      model.isLoading = false;
      onStateChanged();
    }
  }

  String _firebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró un usuario con ese correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta. Intenta de nuevo.';
      case 'invalid-email':
        return e.message ?? 'Correo inválido. Usa el correo institucional.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Contacta soporte.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Espera un momento e intenta de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión. Verifica tu internet.';
      default:
        return e.message ?? 'Error desconocido. Intenta de nuevo.';
    }
  }
}
