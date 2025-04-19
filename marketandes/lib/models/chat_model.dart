import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final DocumentSnapshot chat;
  final DocumentSnapshot userData;
  final String currentUserId;

  ChatModel({
    required this.chat,
    required this.userData,
    required this.currentUserId,
  });
  bool get esComprador => chat['uuidUser'].id == currentUserId;
  String get fechaInicio => chat['timeBegin'];
  String get showed => chat['showed'];
  String get razon {
    final isOwner = chat['uuidOwner'].id == currentUserId;

    return isOwner
        ? chat['Razon'] ?? 'Sin razón'
        : chat['RazonUser'] ?? 'Sin razón';
  }

  String get nombreUsuario => userData['fullName'] ?? 'Sin nombre';

  String get id => chat.id;

  String get userPhotoUrl =>
      'https://randomuser.me/api/portraits/men/1.jpg'; // fijo por ahora
}
