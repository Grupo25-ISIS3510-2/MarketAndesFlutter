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

  final _messagesController = StreamController<List<ChatMessage>>.broadcast();
  List<ChatMessage> _messages = [];

  ChatController(this.chatId);

  bool get isProximityMode => _proximityMode;
  String get _localKey => 'chatMessages_$chatId';

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
    _messagesController.close();
  }

  Future<void> loadInitialMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final currentRaw = prefs.getString(_localKey);

    if (currentRaw != null) {
      _messages =
          List<Map<String, dynamic>>.from(
            jsonDecode(currentRaw),
          ).map((m) => ChatMessage.fromMap(m)).toList();
      _messagesController.add(List.from(_messages));
    }
  }

  Future<void> sendMessage(String text) async {
    final newMessage = ChatMessage(
      message: text,
      uuid: userId,
      fecha: DateTime.now(),
      pending: true,
    );

    _messages.add(newMessage);
    _messagesController.add(List.from(_messages));
    await _saveMessagesLocally();

    try {
      final isBuyer = await _isBuyer();
      final subcollection = isBuyer ? 'lastMessageBuyer' : 'lastMessageSelller';

      final lastDocRef = _firestore
          .collection('chatsFlutter')
          .doc(chatId)
          .collection(subcollection)
          .doc('last');

      await lastDocRef.set({
        'message': text,
        'uuid': userId,
        'fecha': Timestamp.now(),
        'showed': false,
      });

      // Éxito: eliminar el pending
      newMessage.pending = false;
      await _saveMessagesLocally();
      _messagesController.add(List.from(_messages));
    } catch (e) {
      print(' Error enviando mensaje: $e');
    }
  }

  Stream<List<ChatMessage>> getMessagesStream() {
    _firestore.collection('chatsFlutter').doc(chatId).snapshots().listen((
      docSnapshot,
    ) async {
      if (!docSnapshot.exists) return;

      final isBuyer = await _isBuyer();
      final sub = isBuyer ? 'lastMessageSelller' : 'lastMessageBuyer';

      final lastSnapshot =
          await _firestore
              .collection('chatsFlutter')
              .doc(chatId)
              .collection(sub)
              .doc('last')
              .get();

      if (lastSnapshot.exists) {
        final data = lastSnapshot.data()!;
        final alreadySeen = data['showed'] == true;

        if (!alreadySeen) {
          final newMessage = ChatMessage(
            message: data['message'],
            uuid: data['uuid'],
            fecha: (data['fecha'] as Timestamp).toDate(),
            pending: false,
          );
          final yaExiste = _messages.any(
            (m) =>
                m.message == newMessage.message &&
                m.uuid == newMessage.uuid &&
                m.fecha.difference(newMessage.fecha).inMilliseconds.abs() <
                    1000,
          );

          if (!yaExiste) {
            _messages.add(newMessage);
            await _saveMessagesLocally();
            _messagesController.add(List.from(_messages));
          }

          await lastSnapshot.reference.update({'showed': true});
        }
      }
    });

    return _messagesController.stream;
  }

  Future<void> _saveMessagesLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localKey,
      jsonEncode(_messages.map((m) => m.toMap()).toList()),
    );
  }

  Future<bool> _isBuyer() async {
    final doc = await _firestore.collection('chatsFlutter').doc(chatId).get();
    return (doc['uuidUser'] as DocumentReference).id == userId;
  }
}
