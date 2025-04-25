import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message_model.dart';
import 'session_state_controller.dart';

class ChatController {
  final String chatId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = currentUserUuid.value;

  StreamSubscription<dynamic>? _proximitySubscription;
  double _previousBrightness = 1.0;
  bool _proximityMode = false;

  ChatController(this.chatId);

  bool get isProximityMode => _proximityMode;
  String get _localKey => 'chatMessages_$chatId';

  // 🔆 Brillo / Proximidad
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

  Future<void> _restoreBrightness() async {
    await ScreenBrightness().setScreenBrightness(_previousBrightness);
  }

  void _stopListeningProximity() {
    _proximitySubscription?.cancel();
    _proximitySubscription = null;
  }

  void dispose() {
    _stopListeningProximity();
  }

  // ✉️ Enviar mensaje
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final newMessage = {
      'message': message.trim(),
      'uuid': userId,
      'fecha': Timestamp.now(),
      'showed': false,
    };

    final isBuyer = await _isBuyer();
    final subcollection = isBuyer ? 'lastMessageBuyer' : 'lastMessageSelller';

    await _firestore.collection('chatsFlutter').doc(chatId).update({
      'timeBegin': Timestamp.now(),
      'showed': false,
    });

    final lastDocRef = _firestore
        .collection('chatsFlutter')
        .doc(chatId)
        .collection(subcollection)
        .doc('last');

    // Intentar update, y fallback a set si falla
    try {
      await lastDocRef.update(newMessage);
    } catch (_) {
      await lastDocRef.set(newMessage);
    }

    final msg = ChatMessage(
      message: message.trim(),
      uuid: userId,
      fecha: DateTime.now(),
    );

    await _addMessageToLocal(msg);
  }

  // 💾 Guardar mensaje local
  Future<void> _addMessageToLocal(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final currentRaw = prefs.getString(_localKey);
    final List<Map<String, dynamic>> localMsgs =
        currentRaw != null
            ? List<Map<String, dynamic>>.from(jsonDecode(currentRaw))
            : [];

    localMsgs.add(message.toMap());
    await prefs.setString(_localKey, jsonEncode(localMsgs));
  }

  // 📨 Cargar mensajes locales y añadir nuevo si existe en Firebase
  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final currentRaw = prefs.getString(_localKey);
    List<ChatMessage> localMessages = [];

    if (currentRaw != null) {
      localMessages =
          List<Map<String, dynamic>>.from(
            jsonDecode(currentRaw),
          ).map((m) => ChatMessage.fromMap(m)).toList();
    }

    try {
      final isBuyer = await _isBuyer();
      final sub = isBuyer ? 'lastMessageSelller' : 'lastMessageBuyer';

      final snapshot =
          await _firestore
              .collection('chatsFlutter')
              .doc(chatId)
              .collection(sub)
              .doc('last')
              .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final alreadySeen = data['showed'] == true;

        if (!alreadySeen) {
          final newMessage = ChatMessage(
            message: data['message'],
            uuid: data['uuid'],
            fecha: (data['fecha'] as Timestamp).toDate(),
          );

          localMessages.add(newMessage);

          await prefs.setString(
            _localKey,
            jsonEncode(localMessages.map((m) => m.toMap()).toList()),
          );

          await snapshot.reference.update({'showed': true});
        }
      }
    } catch (_) {
      print('⚠️ Error de conexión. Usando solo datos locales.');
    }

    return localMessages;
  }

  Future<bool> _isBuyer() async {
    final doc = await _firestore.collection('chatsFlutter').doc(chatId).get();
    return (doc['uuidUser'] as DocumentReference).id == userId;
  }
}
