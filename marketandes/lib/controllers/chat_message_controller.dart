import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../models/chat_message_model.dart';
import 'session_state_controller.dart';

class ChatController {
  final String chatId;
  StreamSubscription<dynamic>? _proximitySubscription;
  double _previousBrightness = 1.0;
  bool _proximityMode = false;

  ChatController(this.chatId);

  bool get isProximityMode => _proximityMode;

  Future<void> initBrightness() async {
    _previousBrightness = await ScreenBrightness().current;
  }

  void toggleProximityMode(bool enabled) {
    _proximityMode = enabled;

    if (enabled) {
      _startListeningProximity();
    } else {
      _stopListeningProximity();
      _restoreBrightness();
    }
  }

  void _startListeningProximity() {
    _proximitySubscription = ProximitySensor.events.listen((event) {
      if (!_proximityMode) return;

      if (event > 0) {
        ScreenBrightness().setScreenBrightness(0.0);
      } else {
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

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chatsFlutter')
        .doc(chatId)
        .collection('messages')
        .add({
          'message': message.trim(),
          'uuid': currentUserUuid.value,
          'fecha': Timestamp.now(),
        });
  }

  Stream<List<ChatMessage>> getMessagesStream() {
    return FirebaseFirestore.instance
        .collection('chatsFlutter')
        .doc(chatId)
        .collection('messages')
        .orderBy('fecha')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        ChatMessage.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  void dispose() {
    _stopListeningProximity();
  }
}
