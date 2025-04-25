import 'package:flutter/material.dart';
import '../../controllers/chat_message_controller.dart';
import '../../models/chat_message_model.dart';
import '../../controllers/session_state_controller.dart';

class ChatConversationPage extends StatefulWidget {
  final String chatId;
  final String userName;
  final String userPhotoUrl;
  final String razon;

  const ChatConversationPage({
    super.key,
    required this.chatId,
    required this.userName,
    required this.userPhotoUrl,
    required this.razon,
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  late ChatController _controller;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ChatController(widget.chatId);
    _controller.initBrightness();
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleProximityMode(bool value) {
    setState(() {
      _controller.toggleProximityMode(value);
    });
  }

  Future<void> _sendMessage() async {
    await _controller.sendMessage(_messageController.text);
    _messageController.clear();
    setState(() {}); // Refresca FutureBuilder tras enviar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Container(height: 4, color: const Color(0xFFFDC500)),
          Expanded(child: _buildMessages()),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF00296B),
      elevation: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          CircleAvatar(backgroundImage: NetworkImage(widget.userPhotoUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  widget.razon,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.visibility_off, color: Colors.white),
              Switch(
                value: _controller.isProximityMode,
                activeColor: const Color(0xFFFDC500),
                onChanged: _toggleProximityMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return FutureBuilder<List<ChatMessage>>(
      future: _controller.loadMessages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMine = message.uuid == currentUserUuid.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment:
                    isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMine)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(widget.userPhotoUrl),
                      ),
                    ),
                  Flexible(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isMine
                                ? const Color(0xFFFDC500)
                                : const Color(0xFF00296B),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isMine ? 16 : 0),
                              topRight: Radius.circular(isMine ? 0 : 16),
                              bottomLeft: const Radius.circular(16),
                              bottomRight: const Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            message.message,
                            style: TextStyle(
                              color: isMine ? Colors.black : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isMine && message.isQueued)
                            Positioned(
                              bottom: -10,
                              right: 8,
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Enviando...',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                      ],
                    ),
                  ),
                  if (isMine) const SizedBox(width: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
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
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
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
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
