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
                child: FutureBuilder<List<ChatModel>>(
                  future: controller.getChats(userId),
                  builder: (context, snapshot) {
                    print(
                      '📡 [UI] Estado snapshot: ${snapshot.connectionState}',
                    );
                    print('📡 [UI] Tiene data: ${snapshot.hasData}');
                    print(
                      '📡 [UI] Chats recibidos: ${snapshot.data?.length ?? 0}',
                    );

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('❌ Error: ${snapshot.error}'),
                        );
                      }

                      final chats = snapshot.data ?? [];

                      if (chats.isEmpty) {
                        return const Center(
                          child: Text('No tienes chats aún.'),
                        );
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
                                if (chat.esComprador)
                                  IconButton(
                                    color: Colors.red,
                                    icon: const Icon(Icons.close),
                                    onPressed: () async {
                                      final confirmar = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text('Cerrar chat'),
                                              content: const Text(
                                                '¿Estás seguro de que deseas cerrar este chat?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Cerrar'),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirmar ?? false) {
                                        await controller.cerrarChat(chat.id);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Chat cerrado exitosamente.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    // fallback para cualquier otro estado
                    return const Center(child: Text('Cargando...'));
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
