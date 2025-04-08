import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preferences_model.dart';
import '../controllers/session_state_controller.dart';

class PreferenciasController {
  final PreferenciasModel model;

  PreferenciasController(this.model);

  void toggleOpcion(String opcion) {
    if (model.seleccionadas.contains(opcion)) {
      model.seleccionadas.remove(opcion);
    } else {
      model.seleccionadas.add(opcion);
    }
  }

  bool isSeleccionada(String opcion) {
    return model.seleccionadas.contains(opcion);
  }

  Future<void> guardarPreferencias() async {
    final String? uid = currentUserUuid.value;

    if (uid == null || uid.isEmpty) {
      print('UID no disponible');
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'preferencias': model.seleccionadas.toList(),
    });

    print('Preferencias actualizadas para el usuario $uid');
  }
}
