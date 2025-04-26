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

  String get _uuidUserId {
    final raw = chatData['uuidUser'];
    if (raw is DocumentReference) return raw.id;
    if (raw is Map && raw.containsKey('id')) return raw['id'];
    return '';
  }

  String get _uuidOwnerId {
    final raw = chatData['uuidOwner'];
    if (raw is DocumentReference) return raw.id;
    if (raw is Map && raw.containsKey('id')) return raw['id'];
    return '';
  }

  bool get esComprador => _uuidUserId == currentUserId;

  String get fechaInicio {
    final value = chatData['timeBegin'];
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is String) return value;
    return '';
  }

  String get showed {
    final value = chatData['showed'];
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is String) return value;
    return '';
  }

  String get razon {
    final isOwner = _uuidOwnerId == currentUserId;
    return isOwner
        ? chatData['Razon'] ?? 'Sin razón'
        : chatData['RazonUser'] ?? 'Sin razón';
  }

  String get nombreUsuario => userData['fullName'] ?? 'Sin nombre';
  String get id => chatData['id'];
  String get userPhotoUrl => 'https://randomuser.me/api/portraits/men/1.jpg';
  double get latitudPuntoEncuentro {
    final valor = chatData['latitudPuntoEncuentro'];
    return valor is num ? valor.toDouble() : 0.0;
  }

  double get longitudPuntoEncuentro {
    final valor = chatData['longitudPuntoEncuentro'];
    return valor is num ? valor.toDouble() : 0.0;
  }
}
