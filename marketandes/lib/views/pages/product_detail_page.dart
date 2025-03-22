import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketandes/widgets/navbar_widget.dart';
import 'package:marketandes/views/pages/rating_form_page.dart';
import 'package:marketandes/data/session_timer.dart';
import '../../data/notifiers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import '../widget_tree.dart';


class ProductDetailPage extends StatelessWidget {
  final String name;
  final int price;
  final String? imagePath;
  final String description;
  final String sellerID;
  final int sellerRating;
  final String sellerUUID;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.price,
    this.imagePath,
    required this.description,
    required this.sellerID,
    required this.sellerRating,
    required this.sellerUUID,
  });

  Future<void> _handleInteractionAndLogTime() async {
    if (sessionStartTime == null) return;

    final now = DateTime.now();
    final duration = now.difference(sessionStartTime!);

    if (duration.inMinutes < 5) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('purchaseTime').add({
          'uid': uid,
          'elapsedTime': duration.inSeconds,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: SizedBox(
          height: 60,
          child: Image.asset(
            "assets/images/MartekAndesAppBar.png",
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    if (imagePath != null)
                      Image.network(
                        imagePath!,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00296B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "\$${price.toString()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 24,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sellerID,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  sellerRating,
                  (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                description,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDC500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      
                      onPressed: () async {
                        await _handleInteractionAndLogTime();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RatingFormPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Comprar",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00296B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {

                        await _handleInteractionAndLogTime();


                        final String compradorUid = currentUserUuid.value;
                        final String vendedorUid = sellerID;

                        if (compradorUid.isEmpty) {
                          print('UID del comprador no disponible');
                          return;
                        }

                        try {
                          // Referencias a los documentos de los usuarios
                          final compradorRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(compradorUid);
                          final vendedorRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(sellerUUID);

                          // Crear el documento del chat
                          await FirebaseFirestore.instance
                              .collection('chatsFlutter')
                              .add({
                                'Razon': 'Comprador $name',
                                'RazonUser': 'Vendedor $name',
                                'latitud': 0,
                                'longitud': 0,
                                'latitudPuntoEncuentro': 0,
                                'longitudPuntoEncuentro': 0,
                                'uuidUser': compradorRef, // comprador
                                'uuidOwner': vendedorRef, // vendedor
                              });

                          print('Chat creado exitosamente');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const HomeWithNavbar(selectedIndex: 2),
                            ),
                          );

                          // Aquí podrías hacer un Navigator.push para abrir el chat si quieres
                        } catch (error) {
                          print('Error al crear el chat: $error');
                        }

                      },
                      child: const Text(
                        "Contactar Vendedor",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavbarWidget(
        selectedIndex: 0,
        onItemTapped: (index) {
          Navigator.pop(context);
        },
      ),
    );
  }
}
