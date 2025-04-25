import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChatMessage {
  final String message;
  final String uuid;
  final DateTime fecha;
  final bool isQueued;

  ChatMessage({required this.message, required this.uuid, required this.fecha, required this.isQueued});

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      message: data['message'] ?? '',
      uuid: data['uuid'] ?? '',
      fecha: DateTime.parse(data['fecha']),
      isQueued: data['isQueued'] ?? false
    );
  }

  Map<String, dynamic> toMap() {
    return {'message': message, 'uuid': uuid, 'fecha': fecha.toIso8601String(), 'isQueued': isQueued};
  }
}
