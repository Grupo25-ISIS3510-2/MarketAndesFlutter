import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import '../../controllers/session_state_controller.dart'; // Donde está currentUserUuid

class PreferenciasScreen extends StatefulWidget {
  const PreferenciasScreen({super.key});
  @override
  State<PreferenciasScreen> createState() => _PreferenciasScreenState();
}

class _PreferenciasScreenState extends State<PreferenciasScreen> {
  final List<String> _opciones = [
    'Arte',
    'Fisica',
    'Utensilios',
    'Diseño',
    'Lenguas',
    'Ingenieria',
    'Libros',
    'Medicina',
    'Tecnología',
    'Administración',
    'Software',
    'Música',
    'Arquitectura',
    'Psicología',
    'Educación',
    'Química',
    'Economía',
    'Ciencias',
    'Derecho',
    'Ingles',
  ];

  final Set<String> _seleccionadas = {'Software', 'Derecho'};

  // Método para guardar preferencias en Firestore
  Future<void> guardarPreferencias() async {
    try {
      final String? uid = currentUserUuid.value;

      if (uid == null || uid.isEmpty) {
        print('UID no disponible');
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'preferencias': _seleccionadas.toList(),
      });

      print('Preferencias actualizadas para el usuario $uid');
      Navigator.pushReplacementNamed(context, '/home'); // Ir a Home
    } catch (error) {
      print('Error al guardar preferencias: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xff002366)),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              const Text(
                'Preferencias',
                style: TextStyle(
                  color: Color(0xff002366),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Déjanos saber tus gustos e intereses para recomendarte mejores productos!',
                style: TextStyle(color: Color(0xff6e6e6e), fontSize: 14),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        _opciones.map((opcion) {
                          final bool isSelected = _seleccionadas.contains(
                            opcion,
                          );
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _seleccionadas.remove(opcion);
                                } else {
                                  _seleccionadas.add(opcion);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(0xff002366)
                                        : const Color(0xfff5f5f5),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? const Color(0xffffc107)
                                          : const Color(0xffe0e0e0),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                opcion,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : const Color(0xff6e6e6e),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff002366),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    await guardarPreferencias();
                  },
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
