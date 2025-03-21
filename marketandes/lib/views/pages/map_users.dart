import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaEncuentroPage extends StatelessWidget {
  final String nombreUsuario;

  const MapaEncuentroPage({super.key, required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    // Coordenadas aleatorias en Bogotá para pruebas
    final LatLng miUbicacion = _randomPointEnBogota();
    final LatLng puntoEncuentro = _randomPointEnBogota();
    final LatLng ubicacionOtraPersona = _randomPointEnBogota();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: Row(
          children: [
            const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Encuentro con $nombreUsuario',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Punto de encuentro con $nombreUsuario',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF00296B),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(center: puntoEncuentro, zoom: 14),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    _crearMarker(miUbicacion, 'Tú', Colors.blue),
                    _crearMarker(
                      ubicacionOtraPersona,
                      nombreUsuario,
                      Colors.green,
                    ),
                    _crearMarker(puntoEncuentro, 'Encuentro', Colors.red),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [miUbicacion, puntoEncuentro],
                      strokeWidth: 4.0,
                      color: Colors.blueAccent,
                    ),
                    Polyline(
                      points: [ubicacionOtraPersona, puntoEncuentro],
                      strokeWidth: 4.0,
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _crearMarker(LatLng point, String label, Color color) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: point,
      builder:
          (ctx) => Column(
            children: [
              Icon(Icons.location_pin, size: 40, color: color),
              Container(
                color: Colors.white,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }

  LatLng _randomPointEnBogota() {
    final random = Random();
    final lat = 4.6 + random.nextDouble() * 0.2;
    final lng = -74.15 + random.nextDouble() * 0.1;
    return LatLng(lat, lng);
  }
}
