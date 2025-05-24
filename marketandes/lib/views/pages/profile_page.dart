import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final Color azulOscuro = const Color(0xFF00296B);
  final Color amarillo = const Color(0xFFFCD900);
  final Color grisClaro = const Color(0xFFF5F5F5);

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClaro,
      appBar: AppBar(
        backgroundColor: azulOscuro,
        title: const Text("Mi perfil"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Acción futura para editar
            },
          ),
        ],
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
              child: Text("No se pudo cargar la información del perfil"),
            );
          }

          final data = snapshot.data!.data()!;
          final nombre = data['fullName'] ?? 'Nombre no disponible';
          final email = data['email'] ?? 'Correo no disponible';
          final favoritos = List<String>.from(data['favoritos'] ?? []);
          final preferencias = List<String>.from(data['preferencias'] ?? []);
          final lat = data['latitud']?.toString() ?? '---';
          final lng = data['longitud']?.toString() ?? '---';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: azulOscuro,
                      child: Text(
                        nombre.isNotEmpty ? nombre[0] : "?",
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: azulOscuro),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Color(0xFF00296B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Información básica"),
              _buildCardItem("👤 Nombre", nombre),
              _buildCardItem("📧 Correo", email),

              const SizedBox(height: 20),
              _buildSectionTitle("Favoritos"),
              if (favoritos.isEmpty)
                _buildCardItem("⭐", "Sin elementos favoritos")
              else
                ...favoritos.map((f) => _buildCardItem("⭐", f)),

              const SizedBox(height: 20),
              _buildSectionTitle("Preferencias"),
              if (preferencias.isEmpty)
                _buildCardItem("", "Sin preferencias")
              else
                ...preferencias.map((p) => _buildCardItem("", p)),

              const SizedBox(height: 20),
              _buildSectionTitle("Ubicación"),
              _buildCardItem("📍 Latitud", lat),
              _buildCardItem("📍 Longitud", lng),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: azulOscuro,
        ),
      ),
    );
  }

  Widget _buildCardItem(String label, String content) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: Text(label, style: TextStyle(fontSize: 20, color: azulOscuro)),
        title: Text(content, style: TextStyle(fontSize: 16, color: azulOscuro)),
      ),
    );
  }
}
