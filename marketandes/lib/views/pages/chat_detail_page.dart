import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../controllers/session_state_controller.dart'; // para el currentUserUuid

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
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _proximityMode = false;
  StreamSubscription<dynamic>? _proximitySubscription;
  double _previousBrightness = 1.0;

  @override
  void initState() {
    super.initState();
    _initBrightness();
  }

  Future<void> _initBrightness() async {
    _previousBrightness = await ScreenBrightness().current;
  }

  void _toggleProximityMode(bool enabled) {
    setState(() {
      _proximityMode = enabled;
    });

    if (enabled) {
      _startListeningProximity();
    } else {
      _stopListeningProximity();
      _restoreBrightness();
    }
  }

  void _startListeningProximity() {
    _proximitySubscription = ProximitySensor.events.listen((int event) {
      if (!_proximityMode) return;

      if (event > 0) {
        // Algo cerca, apaga pantalla
        ScreenBrightness().setScreenBrightness(0.0);
      } else {
        // Nada cerca, restaura brillo
        _restoreBrightness();
      }
    });
  }

  void _stopListeningProximity() {
    _proximitySubscription?.cancel();
    _proximitySubscription = null;
  }

  Future<void> _restoreBrightness() async {
    await ScreenBrightness().setScreenBrightness(_previousBrightness);
  }

  @override
  void dispose() {
    _stopListeningProximity();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
              Icon(
                Icons.visibility_off, // Ícono antiespías
                color: Colors.white,
              ),
              Switch(
                value: _proximityMode,
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
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('chatsFlutter')
              .doc(widget.chatId)
              .collection('messages')
              .orderBy('fecha', descending: false)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay mensajes aún.'));
        }

        final messages = snapshot.data!.docs;

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
            final messageData = messages[index].data() as Map<String, dynamic>;
            final messageText = messageData['message'] ?? '';
            final senderUuid = messageData['uuid'] ?? '';

            final isMine = senderUuid == currentUserUuid.value;

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
                          topLeft: Radius.circular(isMine ? 16 : 0),
                          topRight: Radius.circular(isMine ? 0 : 16),
                          bottomLeft: const Radius.circular(16),
                          bottomRight: const Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        messageText,
                        style: TextStyle(
                          color: isMine ? Colors.black : Colors.white,
                          fontSize: 14,
                        ),
                      ),
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chatsFlutter')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'message': text,
          'uuid': currentUserUuid.value,
          'fecha': Timestamp.now(),
        });

    _messageController.clear();
  }
}
