import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String message;
  final String uuid;
  final DateTime fecha;
  bool pending; // Nuevo campo

  ChatMessage({
    required this.message,
    required this.uuid,
    required this.fecha,
    this.pending = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      message: data['message'] ?? '',
      uuid: data['uuid'] ?? '',
      fecha: DateTime.parse(data['fecha']),
      pending: data['pending'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'uuid': uuid,
      'fecha': fecha.toIso8601String(),
      'pending': pending,
    };
  }
}