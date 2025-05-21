import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  LatLng? _currentPosition;
  double _heading = 0.0;
  bool _hasConnection = true;
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  final List<Map<String, dynamic>> _pointsOfInterest = [
    {
      "name": "Papelería Central",
      "type": "Papelería",
      "location": LatLng(4.601722, -74.065948),
      "radius": 200.0,
    },
    {
      "name": "Librería Estudiantil",
      "type": "Librería",
      "location": LatLng(4.602334, -74.064832),
      "radius": 150.0,
    },
    {
      "name": "Tienda Académica",
      "type": "Tienda de útiles",
      "location": LatLng(4.600841, -74.065512),
      "radius": 180.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _connectivity = Connectivity();
    _checkInitialConnectivity();
    _listenToConnectivity();
    _getUserLocation();
  }

  void _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      _hasConnection = result != ConnectivityResult.none;
    });
  }

  void _listenToConnectivity() {
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen((ConnectivityResult result) {
      setState(() {
        _hasConnection = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _heading = position.heading;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentPosition != null) {
        _mapController.move(_currentPosition!, 15.0);
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasConnection) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF00296B),
          title: const Text("Mapa con Puntos de Interés"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/NoInternet.jpg',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                'No hay conexión a internet.\nNo es posible cargar el mapa.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: const Text("Mapa con Puntos de Interés"),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentPosition!,
                zoom: 15.0,
                minZoom: 10.0,
                maxZoom: 18.0,
                rotation: 0,
                interactiveFlags: InteractiveFlag.all,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  rotate: true,
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 40,
                      height: 40,
                      rotate: false,
                      builder: (ctx) => const Icon(
                        Icons.navigation,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                    ..._pointsOfInterest.map((rawPoi) {
                      final Map<String, dynamic> poi = rawPoi;
                      return Marker(
                        point: poi["location"],
                        width: 40,
                        height: 40,
                        rotate: true,
                        builder: (ctx) => GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(poi["name"]),
                                  content: Text("Tipo de tienda: ${poi["type"]}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text("Cerrar"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Image.asset(
                            'assets/images/storeicon.png',
                            width: 32,
                            height: 32,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
    );
  }
}
