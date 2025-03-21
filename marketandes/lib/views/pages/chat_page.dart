import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/notifiers.dart';
import 'chat_detail_page.dart';
import 'map_users.dart'; // ChatConversationPage está aquí

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currentUserUuid,
      builder: (context, userId, _) {
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
              Container(height: 2, color: const Color(0xFFFDC500)),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('chatsFlutter')
                          .where(
                            'uuidOwner',
                            isEqualTo: FirebaseFirestore.instance.doc(
                              '/users/$userId',
                            ),
                          )
                          .snapshots(),
                  builder: (context, ownerSnapshot) {
                    return StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('chatsFlutter')
                              .where(
                                'uuidUser',
                                isEqualTo: FirebaseFirestore.instance.doc(
                                  '/users/$userId',
                                ),
                              )
                              .snapshots(),
                      builder: (context, userSnapshot) {
                        if (ownerSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final chats = [
                          ...ownerSnapshot.data?.docs ?? [],
                          ...userSnapshot.data?.docs ?? [],
                        ];

                        if (chats.isEmpty) {
                          return const Center(
                            child: Text('No tienes chats aún.'),
                          );
                        }

                        return ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];

                            final uuidOwnerRef =
                                chat['uuidOwner'] as DocumentReference;
                            final uuidUserRef =
                                chat['uuidUser'] as DocumentReference;

                            final isOwner = uuidOwnerRef.id == userId;
                            final razon =
                                isOwner
                                    ? chat['Razon'] ?? 'Sin razón'
                                    : chat['RazonUser'] ?? 'Sin razón';

                            final userRef =
                                isOwner ? uuidUserRef : uuidOwnerRef;

                            return FutureBuilder<DocumentSnapshot>(
                              future: userRef.get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const ListTile(
                                    title: Text('Cargando...'),
                                  );
                                }

                                if (!userSnapshot.hasData ||
                                    !userSnapshot.data!.exists) {
                                  return const ListTile(
                                    title: Text('Usuario no encontrado'),
                                  );
                                }

                                final userData = userSnapshot.data!;
                                final nombre =
                                    userData['fullName'] ?? 'Sin nombre';

                                const userPhotoUrl =
                                    'https://randomuser.me/api/portraits/men/1.jpg';
                                final chatId = chat.id;

                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundImage: NetworkImage(userPhotoUrl),
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => MapaEncuentroPage(
                                                    nombreUsuario: nombre,
                                                    chatId:
                                                        chatId, // aquí pasas el id del chat
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        color: Colors.black,
                                        icon: const Icon(
                                          Icons.chat_bubble_outline,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ChatConversationPage(
                                                        chatId: chatId,
                                                        userName: nombre,
                                                        userPhotoUrl:
                                                            userPhotoUrl,
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
