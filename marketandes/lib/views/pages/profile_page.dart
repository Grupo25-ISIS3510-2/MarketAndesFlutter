import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        title: const Text("Mi perfil"),
        backgroundColor: const Color(0xFF00296B), // Azul oscuro
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00296B)),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "No se pudo cargar la información del perfil",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final nombre = data['fullName'] ?? 'Nombre no disponible';
          final email = data['email'] ?? 'Correo no disponible';
          final favoritos = List<String>.from(data['favoritos'] ?? []);
          final preferencias = List<String>.from(data['preferencias'] ?? []);
          final lat = data['latitud']?.toString() ?? '---';
          final lng = data['longitud']?.toString() ?? '---';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                Text("👤 Nombre", style: _sectionTitleStyle),
                Text(nombre, style: _infoTextStyle),
                const SizedBox(height: 20),

                Text("📧 Correo electrónico", style: _sectionTitleStyle),
                Text(email, style: _infoTextStyle),
                const SizedBox(height: 20),

                Text("⭐ Favoritos", style: _sectionTitleStyle),
                ...favoritos.map((f) => Text("• $f", style: _infoTextStyle)),
                const SizedBox(height: 20),

                Text("🎯 Preferencias", style: _sectionTitleStyle),
                ...preferencias.map((p) => Text("• $p", style: _infoTextStyle)),
                const SizedBox(height: 20),

                Text("📍 Ubicación registrada", style: _sectionTitleStyle),
                Text("Latitud: $lat", style: _infoTextStyle),
                Text("Longitud: $lng", style: _infoTextStyle),
              ],
            ),
          );
        },
      ),
    );
  }

  final TextStyle _sectionTitleStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF00296B), // Azul oscuro
  );

  final TextStyle _infoTextStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
  );
}
