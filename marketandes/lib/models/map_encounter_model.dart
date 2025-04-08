import 'dart:math';
import 'package:latlong2/latlong.dart';

class MapaEncuentroModel {
  static LatLng calcularPuntoMedio(LatLng puntoA, LatLng puntoB) {
    double latitudMedia = (puntoA.latitude + puntoB.latitude) / 2;
    double longitudMedia = (puntoA.longitude + puntoB.longitude) / 2;
    return LatLng(latitudMedia, longitudMedia);
  }

  static LatLng puntoAleatorioBogota() {
    final random = Random();
    final lat = 4.6 + random.nextDouble() * 0.2;
    final lng = -74.15 + random.nextDouble() * 0.1;
    return LatLng(lat, lng);
  }
}
