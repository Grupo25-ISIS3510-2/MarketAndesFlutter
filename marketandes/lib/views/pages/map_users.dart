import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
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
  late LatLng miUbicacion;
  late LatLng ubicacionOtraPersona;
  late LatLng puntoEncuentro;

  List<LatLng> rutaMiUbicacion = [];
  bool cargando = true;

  Stream<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _verificarPermisosYInicializar();
  }

  @override
  void dispose() {
    super.dispose();
    _positionStream = null;
  }

  Future<void> _verificarPermisosYInicializar() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      print('Permiso de ubicación concedido');
      inicializarMapa();
    } else if (status.isDenied) {
      print('Permiso de ubicación denegado');
      _mostrarDialogoPermisoDenegado();
    } else if (status.isPermanentlyDenied) {
      print('Permiso permanentemente denegado');
      _mostrarDialogoIrAjustes();
    }
  }

  void _mostrarDialogoPermisoDenegado() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permiso requerido'),
            content: const Text(
              'Debes permitir el acceso a la ubicación para continuar.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _verificarPermisosYInicializar();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
    );
  }

  void _mostrarDialogoIrAjustes() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permiso denegado permanentemente'),
            content: const Text(
              'Debes habilitar el permiso manualmente en la configuración de la app.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Ir a configuración'),
              ),
            ],
          ),
    );
  }

  Future<void> inicializarMapa() async {
    await obtenerMiUbicacion();

    final chatDoc =
        await FirebaseFirestore.instance
            .collection('chatsFlutter')
            .doc(widget.chatId)
            .get();

    final datosChat = chatDoc.data();

    if (datosChat == null) {
      print('Chat no encontrado');
      return;
    }

    final String uuidUser = (datosChat['uuidUser'] as DocumentReference).id;
    final String uuidOwner = (datosChat['uuidOwner'] as DocumentReference).id;

    print('🔹 uuidUser: $uuidUser');
    print('🔸 uuidOwner: $uuidOwner');
    String miUid = '';
    String otroUid = '';

    if (uuidUser == currentUserUuid.value) {
      miUid = uuidUser;
      otroUid = uuidOwner;
    } else if (uuidOwner == currentUserUuid.value) {
      miUid = uuidOwner;
      otroUid = uuidUser;
    }

    final otroUserDoc =
        await FirebaseFirestore.instance.collection('users').doc(otroUid).get();

    final datosOtroUsuario = otroUserDoc.data();

    if (datosOtroUsuario == null) {
      print('Otro usuario no encontrado');
      return;
    }

    double latOtraPersona = datosOtroUsuario['latitud'] ?? 0.0;
    double lngOtraPersona = datosOtroUsuario['longitud'] ?? 0.0;

    ubicacionOtraPersona = LatLng(latOtraPersona, lngOtraPersona);

    double latPuntoEncuentro = datosChat['latitudPuntoEncuentro'] ?? 0.0;
    double lngPuntoEncuentro = datosChat['longitudPuntoEncuentro'] ?? 0.0;

    if (latPuntoEncuentro == 0.0 && lngPuntoEncuentro == 0.0) {
      puntoEncuentro = calcularPuntoMedio(miUbicacion, ubicacionOtraPersona);

      await FirebaseFirestore.instance
          .collection('chatsFlutter')
          .doc(widget.chatId)
          .update({
            'latitudPuntoEncuentro': puntoEncuentro.latitude,
            'longitudPuntoEncuentro': puntoEncuentro.longitude,
          });

      print('Punto de encuentro calculado y guardado');
    } else {
      puntoEncuentro = LatLng(latPuntoEncuentro, lngPuntoEncuentro);
      print('ℹPunto de encuentro existente encontrado');
    }

    await _obtenerRuta();

    setState(() {
      cargando = false;
    });

    _escucharUbicacionTiempoReal();
  }

  Future<void> obtenerMiUbicacion() async {
    try {
      bool servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        print('Servicios de ubicación deshabilitados');
        miUbicacion = _randomPointEnBogota();
        return;
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.deniedForever ||
            permiso == LocationPermission.denied) {
          print('Permisos de ubicación denegados');
          miUbicacion = _randomPointEnBogota();
          return;
        }
      }

      final posicion = await Geolocator.getCurrentPosition();
      miUbicacion = LatLng(posicion.latitude, posicion.longitude);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUuid.value)
          .update({
            'latitud': miUbicacion.latitude,
            'longitud': miUbicacion.longitude,
          });
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      miUbicacion = _randomPointEnBogota();
    }
  }

  void _escucharUbicacionTiempoReal() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 200, // Se actualiza cada 10 metros
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );

    _positionStream!.listen((Position position) async {
      miUbicacion = LatLng(position.latitude, position.longitude);

      print(
        '📍 Nueva ubicación: ${miUbicacion.latitude}, ${miUbicacion.longitude}',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUuid.value)
          .update({
            'latitud': miUbicacion.latitude,
            'longitud': miUbicacion.longitude,
          });

      await _obtenerRuta();

      // Refresca el mapa
      setState(() {});
    });
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

  LatLng calcularPuntoMedio(LatLng puntoA, LatLng puntoB) {
    double latitudMedia = (puntoA.latitude + puntoB.latitude) / 2;
    double longitudMedia = (puntoA.longitude + puntoB.longitude) / 2;
    return LatLng(latitudMedia, longitudMedia);
  }

  Future<void> recalcularPuntoEncuentro() async {
    await obtenerMiUbicacion();

    puntoEncuentro = calcularPuntoMedio(miUbicacion, ubicacionOtraPersona);

    await FirebaseFirestore.instance
        .collection('chatsFlutter')
        .doc(widget.chatId)
        .update({
          'latitudPuntoEncuentro': puntoEncuentro.latitude,
          'longitudPuntoEncuentro': puntoEncuentro.longitude,
        });

    await _obtenerRuta();

    setState(() {});
    print('Punto de encuentro recalculado');
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
            color: Colors.white,
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
                  onPressed: () async {
                    await recalcularPuntoEncuentro();
                  },
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
