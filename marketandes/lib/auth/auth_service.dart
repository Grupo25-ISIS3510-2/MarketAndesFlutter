import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    User? user; // <- Declaramos el usuario para eliminarlo si algo sale mal

    try {
      // Crear usuario en FirebaseAuth
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      user = userCredential.user; // Asignamos el usuario una vez creado

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'No se pudo crear el usuario en Firebase Auth',
        );
      }

      // Actualizar el displayName en FirebaseAuth
      await user.updateDisplayName(fullName);

      // Guardar info adicional en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential; // Si todo fue bien, devolvemos el resultado
    } catch (e) {
      // Si ocurre un error después de crear el usuario en Auth, lo eliminamos
      if (user != null) {
        try {
          await user.delete();
          debugPrint('Usuario eliminado por error en el registro');
        } catch (deleteError) {
          debugPrint('Error al eliminar el usuario: $deleteError');
        }
      }

      rethrow; // Lanza el error original para manejarlo donde lo llamaste
    }
  }

  Future<void> signout() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
  }
}
