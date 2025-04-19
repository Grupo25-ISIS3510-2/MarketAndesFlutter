import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String message;
  final String uuid;
  final DateTime fecha;

  ChatMessage({required this.message, required this.uuid, required this.fecha});

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      message: data['message'] ?? '',
      uuid: data['uuid'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'message': message, 'uuid': uuid, 'fecha': fecha};
  }
}
