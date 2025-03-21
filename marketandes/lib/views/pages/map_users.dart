import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapaEncuentroPage extends StatefulWidget {
  final String nombreUsuario;

  const MapaEncuentroPage({super.key, required this.nombreUsuario});

  @override
  State<MapaEncuentroPage> createState() => _MapaEncuentroPageState();
}

class _MapaEncuentroPageState extends State<MapaEncuentroPage> {
  final LatLng miUbicacion = _randomPointEnBogota();
  final LatLng puntoEncuentro = _randomPointEnBogota();
  final LatLng ubicacionOtraPersona = _randomPointEnBogota();

  List<LatLng> rutaMiUbicacion = [];
  // Puedes agregar más rutas si quieres, pero de momento lo dejamos solo para ti.

  @override
  void initState() {
    super.initState();
    _obtenerRuta();
  }

  Future<void> _obtenerRuta() async {
    const apiKey = '5b3ce3597851110001cf624884acf4bb7f4849fda1b0d2d33d9cf0d1';
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/foot-walking/geojson',
    );

    final body = jsonEncode({
      "coordinates": [
        [miUbicacion.longitude, miUbicacion.latitude],
        [puntoEncuentro.longitude, puntoEncuentro.latitude],
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
        final List<dynamic> coordinates =
            data['features'][0]['geometry']['coordinates'];

        final List<LatLng> puntosRuta =
            coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

        setState(() {
          rutaMiUbicacion = puntosRuta;
        });
      } else {
        print('Error al obtener la ruta: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener la ruta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: Row(
          children: [
            const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Encuentro con ${widget.nombreUsuario}',
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
                  'Punto de encuentro con ${widget.nombreUsuario}',
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
                      widget.nombreUsuario,
                      Colors.green,
                    ),
                    _crearMarker(puntoEncuentro, 'Encuentro', Colors.red),
                  ],
                ),
                // Ruta real desde mi ubicación al punto de encuentro
                if (rutaMiUbicacion.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: rutaMiUbicacion,
                        strokeWidth: 4.0,
                        color: Colors.blueAccent,
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

  static LatLng _randomPointEnBogota() {
    final random = Random();
    final lat = 4.6 + random.nextDouble() * 0.2;
    final lng = -74.15 + random.nextDouble() * 0.1;
    return LatLng(lat, lng);
  }
}
