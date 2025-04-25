import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final Map<String, dynamic> chatData;
  final Map<String, dynamic> userData;
  final String currentUserId;

  ChatModel({
    required this.chatData,
    required this.userData,
    required this.currentUserId,
  });

  bool get esComprador => chatData['uuidUser']?['id'] == currentUserId;
  String get fechaInicio => chatData['timeBegin'];
  String get showed => chatData['showed'];
  String get razon {
    final isOwner = chatData['uuidOwner']?['id'] == currentUserId;
    return isOwner
        ? chatData['Razon'] ?? 'Sin razón'
        : chatData['RazonUser'] ?? 'Sin razón';
  }

  String get nombreUsuario => userData['fullName'] ?? 'Sin nombre';
  String get id => chatData['id'] ?? 'id-local';
  String get userPhotoUrl => 'https://randomuser.me/api/portraits/men/1.jpg';
}
