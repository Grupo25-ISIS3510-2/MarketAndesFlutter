import 'package:flutter/material.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/session_state_controller.dart';
import '../../models/chat_model.dart';
import 'chat_detail_page.dart';
import 'map_users.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ChatController();

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
                child: StreamBuilder<List<ChatModel>>(
                  stream: controller.getChats(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final chats = snapshot.data ?? [];

                    if (chats.isEmpty) {
                      return const Center(child: Text('No tienes chats aún.'));
                    }

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(chat.userPhotoUrl),
                          ),
                          title: Text(
                            chat.razon,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00296B),
                            ),
                          ),
                          subtitle: Text(
                            chat.nombreUsuario,
                            style: const TextStyle(color: Colors.black),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                color: Colors.black,
                                icon: const Icon(Icons.location_on_outlined),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => MapaEncuentroPage(
                                            nombreUsuario: chat.nombreUsuario,
                                            chatId: chat.id,
                                          ),
                                    ),
                                  );
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
                                          (_) => ChatConversationPage(
                                            chatId: chat.id,
                                            userName: chat.nombreUsuario,
                                            userPhotoUrl: chat.userPhotoUrl,
                                            razon: chat.razon,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
