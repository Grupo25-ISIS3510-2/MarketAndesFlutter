import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import 'chat_local_db_service.dart';

class ChatController {
  final ChatLocalDbService _localDb = ChatLocalDbService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cerrarChat(String chatId) async {
    // Uso de Future con handler (then + catchError)
    await _firestore
        .collection('chatsFlutter')
        .doc(chatId)
        .get()
        .then((doc) async {
          if (!doc.exists) return;

          final data = doc.data()!;
          final compradorRef = data['uuidUser'] as DocumentReference;
          final vendedorRef = data['uuidOwner'] as DocumentReference;
          final now = Timestamp.now();

          // Uso de Future con async/await
          await anadirTiempoRegistro(chatId);

          await compradorRef.update({'lastUpdate': now});
          await vendedorRef.update({'lastUpdate': now});

          await _firestore.collection('chatsFlutter').doc(chatId).delete();
        })
        .catchError((e) {
          print('Error al cerrar el chat: $e');
        });
  }

  Future<void> anadirTiempoRegistro(String chatId) async {
    final doc = await _firestore.collection('chatsFlutter').doc(chatId).get();
    if (doc.exists && doc.data()!.containsKey('initTime')) {
      await _firestore.collection('chatsCerrados').add({
        'chatId': chatId,
        'timeOpened': doc['initTime'],
        'timeClosed': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<ChatModel>> getChats(String userId) async {
    print('[getChats] Iniciando para user: $userId');

    final localUpdate = await _localDb.getLastUpdate(userId);
    final localData = await _localDb.getChats(userId);

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final remoteUpdate = userDoc['lastUpdate'];
    final remoteUpdateStr =
        (remoteUpdate as Timestamp).toDate().toIso8601String();

    print('[getChats] LocalUpdate: $localUpdate');
    print('[getChats] RemoteUpdate: $remoteUpdateStr');

    if (localUpdate == remoteUpdateStr && localData.isNotEmpty) {
      print('[getChats] Usando local con ${localData.length} chats');
      return localData.map((c) {
        return ChatModel(
          chatData: c['chat'],
          userData: c['userData'],
          currentUserId: userId,
        );
      }).toList();
    }

    final snapshot = await _firestore.collection('chatsFlutter').get();
    final filteredDocs =
        snapshot.docs.where((doc) {
          final data = doc.data();
          final uuidOwner = data['uuidOwner'] as DocumentReference;
          final uuidUser = data['uuidUser'] as DocumentReference;
          return uuidOwner.id == userId || uuidUser.id == userId;
        }).toList();

    print('[getChats] Firebase filtrado: ${filteredDocs.length} documentos');

    final chatModelsRaw = await Future.wait(
      filteredDocs.map((chat) async {
        try {
          final uuidOwnerRef = chat['uuidOwner'] as DocumentReference;
          final uuidUserRef = chat['uuidUser'] as DocumentReference;
          final otherUserRef =
              uuidOwnerRef.id == userId ? uuidUserRef : uuidOwnerRef;

          print('🔍 Consultando usuario: ${otherUserRef.path}');
          final userData = await otherUserRef.get();

          if (!userData.exists || userData.data() == null) {
            print('⚠️ Usuario no encontrado: ${otherUserRef.path}');
            return null;
          }

          return ChatModel(
            chatData: {
              ...(chat.data() as Map<String, dynamic>),
              'id': chat.id,
              'uuidUser': chat['uuidUser'],
              'uuidOwner': chat['uuidOwner'],
            },
            userData: userData.data() as Map<String, dynamic>,
            currentUserId: userId,
          );
        } catch (e) {
          print('Error procesando chat ${chat.id}: $e');
          return null;
        }
      }),
    );

    final chatModels = chatModelsRaw.whereType<ChatModel>().toList();

    final toCache =
        chatModels.map((c) {
          final cleanedChat = Map<String, dynamic>.from(c.chatData);
          final cleanedUser = Map<String, dynamic>.from(c.userData);

          cleanedChat.updateAll((key, value) {
            if (value is Timestamp) return value.toDate().toIso8601String();
            if (value is DocumentReference) return {'id': value.id};
            return value;
          });

          cleanedUser.updateAll((key, value) {
            if (value is Timestamp) return value.toDate().toIso8601String();
            return value;
          });

          return {'chat': cleanedChat, 'userData': cleanedUser};
        }).toList();

    await _localDb.saveChats(userId, remoteUpdateStr, toCache);
    print('[getChats] Guardado en local ${chatModels.length} chats');

    return chatModels;
  }
}
