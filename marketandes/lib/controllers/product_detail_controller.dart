import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'session_state_controller.dart';
import 'session_timer_controller.dart';

class ProductDetailController {
  Future<void> logInteractionIfShortSession() async {
    if (sessionStartTime == null) return;

    final now = DateTime.now();
    final duration = now.difference(sessionStartTime!);

    if (duration.inMinutes < 5) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('purchaseTime').add({
          'uid': uid,
          'elapsedTime': duration.inSeconds,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> createChat({
    required String name,
    required String sellerID,
    required String sellerUUID,
  }) async {
    final String compradorUid = currentUserUuid.value;

    if (compradorUid.isEmpty) {
      print('UID del comprador no disponible');
      return;
    }

    try {
      final compradorRef = FirebaseFirestore.instance
          .collection('users')
          .doc(compradorUid);
      final vendedorRef = FirebaseFirestore.instance
          .collection('users')
          .doc(sellerUUID);

      final now = Timestamp.now();

      await FirebaseFirestore.instance.collection('chatsFlutter').add({
        'Razon': 'Comprador $name',
        'RazonUser': 'Vendedor $name',
        'latitud': 0,
        'longitud': 0,
        'latitudPuntoEncuentro': 4.601635,
        'longitudPuntoEncuentro': -74.065415,
        'uuidUser': compradorRef,
        'uuidOwner': vendedorRef,
        'timeBegin': FieldValue.serverTimestamp(),
        'initTime': FieldValue.serverTimestamp(),
        'showed': false,
      });

      await compradorRef.update({'lastUpdate': now});
      await vendedorRef.update({'lastUpdate': now});

      print('Chat creado exitosamente y lastUpdate actualizado');
    } catch (error) {
      print('Error al crear el chat: $error');
    }
  }
}
