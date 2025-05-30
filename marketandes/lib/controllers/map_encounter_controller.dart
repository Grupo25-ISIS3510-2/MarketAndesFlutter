import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:async/async.dart';
import '../../controllers/session_state_controller.dart';
import '../models/map_encounter_model.dart';

class MapaEncuentroController {
  CancelableOperation<List<LatLng>>? _rutaPendiente;

  Future<bool> verificarPermisosUbicacion() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<LatLng> obtenerMiUbicacion() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return MapaEncuentroModel.puntoAleatorioBogota();
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.deniedForever ||
            permiso == LocationPermission.denied) {
          return MapaEncuentroModel.puntoAleatorioBogota();
        }
      }

      final posicion = await Geolocator.getCurrentPosition();
      final ubicacion = LatLng(posicion.latitude, posicion.longitude);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUuid.value)
          .update({
            'latitud': ubicacion.latitude,
            'longitud': ubicacion.longitude,
          });

      return ubicacion;
    } catch (_) {
      return MapaEncuentroModel.puntoAleatorioBogota();
    }
  }

  Future<Map<String, dynamic>?> obtenerDatosChat(String chatId) async {
    final chatDoc =
        await FirebaseFirestore.instance
            .collection('chatsFlutter')
            .doc(chatId)
            .get();
    return chatDoc.data();
  }

  Future<Map<String, dynamic>?> obtenerDatosUsuario(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> actualizarPuntoEncuentro(String chatId, LatLng punto) async {
    await FirebaseFirestore.instance
        .collection('chatsFlutter')
        .doc(chatId)
        .update({
          'latitudPuntoEncuentro': punto.latitude,
          'longitudPuntoEncuentro': punto.longitude,
        });
  }

  Future<List<LatLng>> obtenerRuta(LatLng inicio, LatLng fin) async {
    //  Cancelar operación anterior si aún está en curso
    _rutaPendiente?.cancel();

    final operation = CancelableOperation.fromFuture(
      _obtenerRuta(inicio, fin),
      onCancel: () {
        print('Ruta cancelada antes de completarse');
      },
    );

    _rutaPendiente = operation;

    try {
      final result = await operation.value;
      return result;
    } catch (_) {
      return <LatLng>[];
    }
  }

  Future<List<LatLng>> _obtenerRuta(LatLng inicio, LatLng fin) async {
    const apiKey = '5b3ce3597851110001cf624884acf4bb7f4849fda1b0d2d33d9cf0d1';
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/foot-walking/geojson',
    );

    final body = jsonEncode({
      "coordinates": [
        [inicio.longitude, inicio.latitude],
        [fin.longitude, fin.latitude],
      ],
    });

    final headers = {
      'Authorization': apiKey,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coords =
            data['features'][0]['geometry']['coordinates'];

        return coords
            .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();
      } else {
        print('Error al obtener ruta: Código ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener ruta: $e');
    }

    return <LatLng>[];
  }
}
