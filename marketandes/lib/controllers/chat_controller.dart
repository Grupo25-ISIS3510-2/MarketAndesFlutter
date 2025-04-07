import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatModel>> getChats(String userId) async* {
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

    await for (final ownerSnapshot in ownerStream) {
      final userSnapshot = await userStream.first;

      final chats = [...ownerSnapshot.docs, ...userSnapshot.docs];

      final chatModels = await Future.wait(
        chats.map((chat) async {
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

      yield chatModels;
    }
  }
}
