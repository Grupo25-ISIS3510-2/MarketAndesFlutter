import 'package:flutter/material.dart';

class ChatConversationPage extends StatelessWidget {
  final String userName;
  final String userPhotoUrl;
  final String razon;

  const ChatConversationPage({
    super.key,
    required this.userName,
    required this.userPhotoUrl,
    required this.razon,
  });

  @override
  Widget build(BuildContext context) {
    // Mock de mensajes
    final List<Map<String, dynamic>> messages = [
      {
        'text': 'Hola me interesa el libro',
        'isMine': false,
        'avatar':
            'https://randomuser.me/api/portraits/men/1.jpg', // otro usuario
      },
      {'text': 'Perfecto donde vives', 'isMine': true},
      {
        'text': 'Vivo en Usaquén',
        'isMine': false,
        'avatar':
            'https://randomuser.me/api/portraits/men/1.jpg', // otro usuario
      },
      {'text': 'Yo vivo en Chía', 'isMine': true},
      {
        'text': 'Te parece mejor encontrarnos en la U',
        'isMine': false,
        'avatar':
            'https://randomuser.me/api/portraits/men/1.jpg', // otro usuario
      },
      {'text': 'Listo en el C.', 'isMine': true},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            CircleAvatar(backgroundImage: NetworkImage(userPhotoUrl)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  razon,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(height: 4, color: const Color(0xFFFDC500)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMine = message['isMine'] as bool;

                return Container(
                  margin: EdgeInsets.only(
                    bottom: 12,
                    left: isMine ? 60 : 0,
                    right: isMine ? 0 : 60,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        isMine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMine)
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(
                            message['avatar'] ?? userPhotoUrl,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isMine
                                    ? const Color(0xFFFDC500)
                                    : const Color(0xFF00296B),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                isMine ? 16 : 0,
                              ), // invertido
                              topRight: Radius.circular(
                                isMine ? 0 : 16,
                              ), // invertido
                              bottomLeft: const Radius.circular(16),
                              bottomRight: const Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color: isMine ? Colors.black : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: const Color(0xFF00296B),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF00296B),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFFFDC500)),
            onPressed: () {
              // Aquí puedes implementar lógica para enviar mensaje
            },
          ),
        ],
      ),
    );
  }
}
