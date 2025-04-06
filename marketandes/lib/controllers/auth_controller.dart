import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:device_info_plus/device_info_plus.dart'; 
import 'session_state_controller.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<void> _registerEvent(String eventType, String uid) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String device = "Unknown";

      if (kIsWeb) {
        device = "Web Browser";
      } else {
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await deviceInfo.androidInfo;
          device = '${androidInfo.manufacturer} ${androidInfo.model}';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await deviceInfo.iosInfo;
          device = '${iosInfo.name} ${iosInfo.systemVersion}';
        }
      }

      final eventData = {
        'uid': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'event': eventType, // login, signup, logout
        'platform':
            kIsWeb
                ? 'Web'
                : defaultTargetPlatform == TargetPlatform.android
                ? 'Android'
                : 'iOS',
        'device': device,
      };

      await firestore.collection('loginEvents').add(eventData);
      debugPrint('Evento registrado: $eventType para $uid');
    } catch (e) {
      debugPrint('Error registrando evento $eventType: $e');
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid ?? "";
    currentUserUuid.value = uid;

  
    await _registerEvent('login', uid);

    return credential;
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    User? user;

    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'No se pudo crear el usuario en Firebase Auth',
        );
      }

      await user.updateDisplayName(fullName);
      currentUserUuid.value = user.uid;

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'longitud': -74.065978,
        'latitud': 4.601295,
      });

      
      await _registerEvent('signup', user.uid);

      return userCredential;
    } catch (e) {
      if (user != null) {
        try {
          await user.delete();
          debugPrint('Usuario eliminado por error en el registro');
        } catch (deleteError) {
          debugPrint('Error al eliminar el usuario: $deleteError');
        }
      }

      rethrow;
    }
  }

  Future<void> signout() async {
    final uid = currentUser?.uid;

    await firebaseAuth.signOut();


    if (uid != null) {
      await _registerEvent('logout', uid);
    }
  }

  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
  }
}
