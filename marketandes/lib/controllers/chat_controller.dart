import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart'; // <-- Este es el importante
import '../models/chat_model.dart';
import 'chat_local_storage.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cerrarChat(String chatId) async {
    await anadirTiempoRegistro(chatId);
    await _firestore.collection('chatsFlutter').doc(chatId).delete();
  }

  Future<Stream<List<ChatModel>>> getChatsConCache(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final firebaseUpdate = userDoc['lastUpdate'] ?? '';
    final localUpdate = await ChatLocalStorage.getLocalLastUpdate(userId);

    if (localUpdate == firebaseUpdate) {
      final cached = await ChatLocalStorage.getLocalChats(userId);
      final localModels =
          cached.map((c) {
            return ChatModel(
              chatData: c['chat'],
              userData: c['userData'],
              currentUserId: userId,
            );
          }).toList();
      return Stream.value(localModels);
    } else {
      final stream = getChats(userId);
      stream.first.then((remoteChats) async {
        final serializable =
            remoteChats.map((chat) {
              final chatData = Map<String, dynamic>.from(chat.chat.data()!);
              final userData = Map<String, dynamic>.from(chat.userData.data()!);

              chatData['id'] = chat.id; // aseguramos que el ID esté presente

              return {'chat': chatData, 'userData': userData};
            }).toList();

        await ChatLocalStorage.saveChatsForUser(
          userId,
          serializable,
          firebaseUpdate,
        );
      });

      return stream.map(
        (chatList) =>
            chatList.map((chat) {
              return ChatModel(
                chatData: chat.chat.data()!..['id'] = chat.id,
                userData: chat.userData.data(),
                currentUserId: userId,
              );
            }).toList(),
      );
    }
  }

  Future<void> anadirTiempoRegistro(String chatId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Obtener el initTime del chat original
      final doc = await firestore.collection('chatsFlutter').doc(chatId).get();

      if (doc.exists && doc.data()!.containsKey('initTime')) {
        final initTime = doc['initTime'];

        await firestore.collection('chatsCerrados').add({
          'chatId': chatId,
          'timeOpened': initTime,
          'timeClosed': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception("initTime no encontrado para el chat $chatId");
      }
    } catch (e) {
      print("Error al registrar tiempos del chat: $e");
    }
  }

  Stream<List<ChatModel>> getChats(String userId) {
    final userRef = _firestore.doc('/users/$userId');

    final ownerStream =
        _firestore
            .collection('chatsFlutter')
            .where('uuidOwner', isEqualTo: userRef)
            .snapshots();

    final userStream =
        _firestore
            .collection('chatsFlutter')
            .where('uuidUser', isEqualTo: userRef)
            .snapshots();

    return Rx.combineLatest2(ownerStream, userStream, (
      QuerySnapshot ownerSnapshot,
      QuerySnapshot userSnapshot,
    ) async {
      final allDocs = [...ownerSnapshot.docs, ...userSnapshot.docs];

      final chatModels = await Future.wait(
        allDocs.map((chat) async {
          final uuidOwnerRef = chat['uuidOwner'] as DocumentReference;
          final uuidUserRef = chat['uuidUser'] as DocumentReference;
          final otherUserRef =
              uuidOwnerRef.id == userId ? uuidUserRef : uuidOwnerRef;

          final userData = await otherUserRef.get();

          return ChatModel(
            chat: chat,
            userData: userData,
            currentUserId: userId,
          );
        }),
      );

      return chatModels;
    }).asyncMap((future) => future); // <-- Muy importante: espera el Future
  }
}
