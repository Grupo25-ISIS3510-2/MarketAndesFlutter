import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaSeleccionPage extends StatefulWidget {
  final double latitudSugerida;
  final double longitudSugerida;

  const MapaSeleccionPage({
    super.key,
    required this.latitudSugerida,
    required this.longitudSugerida,
  });

  @override
  State<MapaSeleccionPage> createState() => _MapaSeleccionPageState();
}

class _MapaSeleccionPageState extends State<MapaSeleccionPage> {
  late LatLng _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.latitudSugerida, widget.longitudSugerida);
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona de encuentro con el vendedor'),
        backgroundColor: const Color(0xFF00296B),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _selectedLocation,
              zoom: 16,
              onTap: (_, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80,
                    height: 80,
                    point: LatLng(
                      widget.latitudSugerida,
                      widget.longitudSugerida,
                    ),
                    builder:
                        (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40,
                        ),
                  ),
                  Marker(
                    width: 80,
                    height: 80,
                    point: _selectedLocation,
                    builder:
                        (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDC500),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
              child: const Text('Confirmar ubicación'),
            ),
          ),
        ],
      ),
    );
  }
}
