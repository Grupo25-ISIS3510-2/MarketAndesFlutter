import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Tus notifiers vienen de otro archivo que defines tú
import '../../data/notifiers.dart';
import 'chat_detail_page.dart'; // Aquí está el currentUserUuid que ya definiste

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currentUserUuid,
      builder: (context, userId, _) {
        // Validación: si el userId no ha sido asignado aún
        if (userId.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Mis chats'),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          body: Column(
            children: [
              Container(
                height: 2,
                color: const Color(0xFFFDC500), // Línea amarilla
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('chatsFlutter')
                          .where(
                            'uuidOwner',
                            isEqualTo: FirebaseFirestore.instance.doc(
                              '/users/$userId',
                            ), // Reference
                            // isEqualTo: userId, // Usa este si uuidOwner es String
                          )
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No tienes chats aún.'));
                    }

                    final chats = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final razon = chat['Razon'] ?? 'Sin razón';
                        final uuidUserRef =
                            chat['uuidUser'] as DocumentReference;

                        return FutureBuilder<DocumentSnapshot>(
                          future: uuidUserRef.get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ListTile(title: Text('Cargando...'));
                            }

                            if (!userSnapshot.hasData ||
                                !userSnapshot.data!.exists) {
                              return const ListTile(
                                title: Text('Usuario no encontrado'),
                              );
                            }

                            final userData = userSnapshot.data!;
                            final nombre = userData['fullName'] ?? 'Sin nombre';

                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://randomuser.me/api/portraits/men/1.jpg',
                                ),
                              ),
                              title: Text(
                                razon,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00296B),
                                ),
                              ),
                              subtitle: Text(
                                nombre,
                                style: const TextStyle(color: Colors.black),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    color: Colors.black,
                                    icon: const Icon(
                                      Icons.location_on_outlined,
                                    ),
                                    onPressed: () {
                                      // Lógica futura para ubicación
                                    },
                                  ),
                                  IconButton(
                                    color: Colors.black,
                                    icon: const Icon(Icons.chat_bubble_outline),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ChatConversationPage(
                                                userName:
                                                    nombre, // el que traes de Firebase
                                                userPhotoUrl:
                                                    'https://randomuser.me/api/portraits/men/1.jpg', // o la que traigas
                                                razon: razon,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
