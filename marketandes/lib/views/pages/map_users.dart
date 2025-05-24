import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // <-- Importar
import '../../controllers/map_encounter_controller.dart';
import '../../models/map_encounter_model.dart';
import '../../controllers/session_state_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapaEncuentroPage extends StatefulWidget {
  final String nombreUsuario;
  final String chatId;

  const MapaEncuentroPage({
    super.key,
    required this.nombreUsuario,
    required this.chatId,
  });

  @override
  State<MapaEncuentroPage> createState() => _MapaEncuentroPageState();
}

class _MapaEncuentroPageState extends State<MapaEncuentroPage> {
  final _controller = MapaEncuentroController();

  late LatLng miUbicacion;
  late LatLng ubicacionOtraPersona;
  late LatLng puntoEncuentro;
  List<LatLng> ruta = [];

  StreamSubscription<Position>? _stream;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool cargando = true;
  bool tieneConexion = true;

  @override
  void initState() {
    super.initState();
    _verificarConexion();
    _inicializar();
  }

  @override
  void dispose() {
    _stream?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _verificarConexion() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      tieneConexion = connectivityResult != ConnectivityResult.none;
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      setState(() {
        tieneConexion = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> registrarFeatureTime({
    required String featureName,
    required int milliseconds,
  }) async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) return;

    await FirebaseFirestore.instance.collection('featuresTime').add({
      'feature': featureName,
      'timeMs': milliseconds,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> _inicializar() async {
    if (!tieneConexion) {
      setState(() => cargando = false);
      return;
    }

    final inicio = DateTime.now(); // <-- Aquí medimos tiempo

    final permiso = await _controller.verificarPermisosUbicacion();
    if (!permiso) {
      await _mostrarDialogoPermisos();
      return;
    }

    miUbicacion = await _controller.obtenerMiUbicacion();

    final datosChat = await _controller.obtenerDatosChat(widget.chatId);
    if (datosChat == null) return;

    final uuidUser = datosChat['uuidUser'].id;
    final uuidOwner = datosChat['uuidOwner'].id;
    final miUid = currentUserUuid.value;
    final otroUid = (uuidUser == miUid) ? uuidOwner : uuidUser;

    final datosOtro = await _controller.obtenerDatosUsuario(otroUid);
    if (datosOtro == null) return;

    ubicacionOtraPersona = LatLng(
      datosOtro['latitud'] ?? 4.601635,
      datosOtro['longitud'] ?? -74.065415,
    );

    final lat = (datosChat['latitudPuntoEncuentro'] ?? 4.601635).toDouble();
    final lng = (datosChat['longitudPuntoEncuentro'] ?? -74.065415).toDouble();

    puntoEncuentro =
        (lat == 4.601635 && lng == -74.065415)
            ? MapaEncuentroModel.calcularPuntoMedio(
              miUbicacion,
              ubicacionOtraPersona,
            )
            : LatLng(lat, lng);

    if (lat == -74.065415 && lng == -74.065415) {
      await _controller.actualizarPuntoEncuentro(widget.chatId, puntoEncuentro);
    }

    ruta = await _controller.obtenerRuta(miUbicacion, puntoEncuentro);
    setState(() => cargando = false);
    _escucharUbicacion();

    // Guardamos tiempo al final
    final fin = DateTime.now();
    final duracion = fin.difference(inicio).inMilliseconds;
    registrarFeatureTime(featureName: 'map', milliseconds: duracion);
  }

  Future<void> _mostrarDialogoPermisos() async {
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Permiso requerido'),
            content: const Text(
              'Debes permitir el acceso a la ubicación para continuar.',
            ),
            actions: [
              TextButton(
                child: const Text('Abrir configuración'),
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _escucharUbicacion() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 200,
    );

    _stream = Geolocator.getPositionStream(locationSettings: settings).listen((
      position,
    ) async {
      final nuevaUbicacion = LatLng(position.latitude, position.longitude);

      if (nuevaUbicacion != miUbicacion) {
        miUbicacion = nuevaUbicacion;
        final nuevaRuta = await _controller.obtenerRuta(
          miUbicacion,
          puntoEncuentro,
        );

        if (!listEquals(ruta, nuevaRuta)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                ruta = nuevaRuta;
              });
            }
          });
        }
      }
    });
  }

  Future<void> _recalcularPunto() async {
    miUbicacion = await _controller.obtenerMiUbicacion();
    puntoEncuentro = MapaEncuentroModel.calcularPuntoMedio(
      miUbicacion,
      ubicacionOtraPersona,
    );
    await _controller.actualizarPuntoEncuentro(widget.chatId, puntoEncuentro);
    final nuevaRuta = await _controller.obtenerRuta(
      miUbicacion,
      puntoEncuentro,
    );

    if (!listEquals(ruta, nuevaRuta)) {
      setState(() {
        ruta = nuevaRuta;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si no hay conexión, mostrar imagen y texto
    if (!tieneConexion) {
      return Scaffold(
        backgroundColor: Colors.white, // <-- Fondo blanco
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
        body: Container(
          color: Colors.white, // <-- Asegura fondo blanco en todo
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No hay conexión a internet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No es posible cargar el mapa.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/NoInternet.jpg',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      );
    }

    // Si hay conexión, mostrar mapa normal
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
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  tooltip: 'Recalcular punto de encuentro',
                  onPressed: _recalcularPunto,
                ),
              ],
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              child: FlutterMap(
                options: MapOptions(
                  center: puntoEncuentro,
                  zoom: 14,
                  minZoom: 8,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    keepBuffer: 2, // Usa entero (NO false)
                    backgroundColor: Colors.transparent,
                    tileBuilder:
                        (context, tileWidget, tile) =>
                            RepaintBoundary(child: tileWidget),
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
                  if (ruta.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [
                            for (int i = 0; i < ruta.length; i += 5) ruta[i],
                          ], // menos puntos aún
                          strokeWidth: 4.0,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _crearMarker(LatLng point, String label, Color color) {
    return Marker(
      width: 80,
      height: 80,
      point: point,
      builder:
          (_) => Column(
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
}
