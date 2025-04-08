import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketandes/models/register_model.dart';
import '../controllers/auth_controller.dart';

class RegisterController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  Future<void> register(
    BuildContext context,
    VoidCallback onLoadingChanged,
    Function(String?) onErrorChanged,
  ) async {
    onLoadingChanged.call();
    onErrorChanged(null);

    final model = RegisterModel(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      fullName: fullNameController.text.trim(),
    );

    try {
      if (!model.email.endsWith('@uniandes.edu.co')) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Usa tu correo institucional @uniandes.edu.co',
        );
      }
      if (model.password.length < 8) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Contraseña muy corta debe ser al menos de 8 caracteres.',
        );
      }
      if (model.fullName.isEmpty) {
        throw FirebaseAuthException(
          code: 'wrong-username',
          message: 'Necesita poner un nombre de usuario.',
        );
      }

      await authService.value.createAccount(
        email: model.email,
        password: model.password,
        fullName: model.fullName,
      );

      Navigator.pushNamedAndRemoveUntil(context, '/preferences', (_) => false);
    } on FirebaseAuthException catch (e) {
      onErrorChanged(_firebaseErrorToMessage(e));
    } catch (e) {
      onErrorChanged('Ocurrió un error inesperado. Inténtalo de nuevo.');
    } finally {
      onLoadingChanged.call();
    }
  }

  String _firebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró un usuario con ese correo.';
      case 'wrong-password':
        return e.message ?? 'La contraseña es incorrecta.';
      case 'invalid-email':
        return e.message ?? 'Correo inválido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos.';
      case 'network-request-failed':
        return 'Sin conexión. Verifica tu internet.';
      case 'wrong-username':
        return 'Necesita poner un nombre de usuario.';
      default:
        return e.message ?? 'Error desconocido.';
    }
  }
}
