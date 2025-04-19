import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart'; // <-- Este es el importante
import '../models/chat_model.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cerrarChat(String chatId) async {
    await _firestore.collection('chatsFlutter').doc(chatId).delete();
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
