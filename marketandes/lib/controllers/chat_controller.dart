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

    final userRef = _firestore.collection('users').doc(userId);

    // Paralelizamos local y remoto
    final localUpdateFuture = _localDb.getLastUpdate(userId);
    final localDataFuture = _localDb.getChats(userId);
    final userDocFuture = userRef.get();

    final localUpdate = await localUpdateFuture;
    final localData = await localDataFuture;
    final userDoc = await userDocFuture;

    final remoteUpdate = userDoc['lastUpdate'] as Timestamp;
    final remoteUpdateStr = remoteUpdate.toDate().toIso8601String();

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

    // Filtramos desde Firestore para evitar traer todo
    final snapshot1 =
        await _firestore
            .collection('chatsFlutter')
            .where('uuidUser', isEqualTo: userRef)
            .get();
    final snapshot2 =
        await _firestore
            .collection('chatsFlutter')
            .where('uuidOwner', isEqualTo: userRef)
            .get();
    final allDocs = {...snapshot1.docs, ...snapshot2.docs}.toList();

    print('[getChats] Firebase filtrado: ${allDocs.length} documentos');

    final chatModelsRaw = await Future.wait(
      allDocs.map((chat) async {
        try {
          final data = chat.data();
          final uuidOwnerRef = data['uuidOwner'] as DocumentReference;
          final uuidUserRef = data['uuidUser'] as DocumentReference;
          final otherUserRef =
              uuidOwnerRef.id == userId ? uuidUserRef : uuidOwnerRef;

          print('🔍 Consultando usuario: ${otherUserRef.path}');
          final userDataDoc = await otherUserRef.get();

          if (!userDataDoc.exists || userDataDoc.data() == null) {
            print('⚠️ Usuario no encontrado: ${otherUserRef.path}');
            return null;
          }

          return ChatModel(
            chatData: {
              ...data,
              'id': chat.id,
              'uuidUserId': uuidUserRef.id,
              'uuidOwnerId': uuidOwnerRef.id,
            },
            userData: userDataDoc.data() as Map<String, dynamic>,
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
