import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/map_encounter_controller.dart';
import '../../models/map_encounter_model.dart';
import '../../controllers/session_state_controller.dart';

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
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }

  Future<void> _inicializar() async {
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
      datosOtro['latitud'] ?? 0.0,
      datosOtro['longitud'] ?? 0.0,
    );

    final lat = datosChat['latitudPuntoEncuentro'] ?? 0.0;
    final lng = datosChat['longitudPuntoEncuentro'] ?? 0.0;

    puntoEncuentro =
        (lat == 0.0 && lng == 0.0)
            ? MapaEncuentroModel.calcularPuntoMedio(
              miUbicacion,
              ubicacionOtraPersona,
            )
            : LatLng(lat, lng);

    if (lat == 0.0 && lng == 0.0) {
      await _controller.actualizarPuntoEncuentro(widget.chatId, puntoEncuentro);
    }

    ruta = await _controller.obtenerRuta(miUbicacion, puntoEncuentro);
    setState(() => cargando = false);
    _escucharUbicacion();
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
      miUbicacion = LatLng(position.latitude, position.longitude);
      ruta = await _controller.obtenerRuta(miUbicacion, puntoEncuentro);
      setState(() {});
    });
  }

  Future<void> _recalcularPunto() async {
    miUbicacion = await _controller.obtenerMiUbicacion();
    puntoEncuentro = MapaEncuentroModel.calcularPuntoMedio(
      miUbicacion,
      ubicacionOtraPersona,
    );
    await _controller.actualizarPuntoEncuentro(widget.chatId, puntoEncuentro);
    ruta = await _controller.obtenerRuta(miUbicacion, puntoEncuentro);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                        points: ruta,
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
