import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketandes/views/pages/chat_page.dart';
import 'package:marketandes/views/pages/home_page.dart';
import 'package:marketandes/views/pages/add_page.dart';
import 'package:marketandes/views/pages/map_page.dart';
import 'package:marketandes/views/pages/login_page.dart';
import 'package:marketandes/views/widgets/navbar_widget.dart';
import 'package:marketandes/controllers/session_state_controller.dart';
import 'package:marketandes/views/pages/favorites_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:marketandes/controllers/auth_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeWithNavbar extends StatefulWidget {
  final int selectedIndex;

  const HomeWithNavbar({super.key, this.selectedIndex = 0});

  @override
  State<HomeWithNavbar> createState() => _HomeWithNavbarState();
}

class _HomeWithNavbarState extends State<HomeWithNavbar> {
  late int _selectedIndex;
  bool isConnected = true;
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;
  bool _alreadyRetried = false;
  bool _mostrarCuadroComprador = false;
  bool _mostrarCuadroVendedor = false;
  List<String> _productosPendientes = [];
  List<String> _productosPendientesVendedor = [];
  List<DocumentSnapshot> _docsPendientesComprador = [];
  List<DocumentSnapshot> _docsPendientesVendedor = [];

  final List<Widget> _pages = [HomePage(), AddPage(), ChatPage()];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _revisarComprasPendientes();
    _revisarVentasPendientes();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;

    _checkInitialConnection();

    if (isOfflineLogin) {
      _listenToConnectivity();
    }
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      isConnected = result != ConnectivityResult.none;
    });

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Estás conectado offline"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _listenToConnectivity() {
    _connectivityStream.listen((ConnectivityResult result) async {
      final nowConnected = result != ConnectivityResult.none;
      if (nowConnected && !isConnected) {
        setState(() {
          isConnected = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Has recuperado la conexión. Recargando..."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        if (!_alreadyRetried) {
          _alreadyRetried = true;

          try {
            final box = Hive.box('offlineUsers');
            final offline = box.get(currentUserUuid.value);

            if (offline != null) {
              await authService.value.signInSafe(
                email: offline['email'],
                password: offline['password'],
              );

              // 🔽🔽🔽 INSERTAR DESDE AQUÍ 🔽🔽🔽
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeWithNavbar(),
                  ),
                );
              }
              // 🔼🔼🔼 HASTA AQUÍ 🔼🔼🔼
            }
          } catch (e) {
            debugPrint("❌ Error al intentar re-autenticar: $e");
          }
        }
      } else if (!nowConnected) {
        setState(() {
          isConnected = false;
          _alreadyRetried = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Estás desconectado de internet"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    bool confirmLogout =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Cerrar sesión"),
              content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Cerrar sesión",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmLogout) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _revisarComprasPendientes() async {
    try {
      final uid = currentUserUuid.value;
      final limite = DateTime.now().subtract(const Duration(days: 5));
      final query =
          await FirebaseFirestore.instance
              .collection('chatsFlutter')
              .where(
                'uuidUser',
                isEqualTo: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid),
              )
              .where('timeBegin', isLessThan: Timestamp.fromDate(limite))
              .where('showed', isEqualTo: false)
              .get();

      if (query.docs.isNotEmpty) {
        final productos =
            query.docs
                .map(
                  (doc) =>
                      (doc['Razon'] as String?)?.replaceFirst(
                        'Comprador ',
                        '',
                      ) ??
                      '',
                )
                .toList();
        setState(() {
          _mostrarCuadroComprador = true;
          _productosPendientes = productos;
          _docsPendientesComprador = query.docs;
        });
      }
    } catch (e) {
      debugPrint('Error al revisar compras pendientes: $e');
    }
  }

  Future<void> _revisarVentasPendientes() async {
    try {
      final uid = currentUserUuid.value;
      final limite = DateTime.now().subtract(const Duration(days: 5));
      final query =
          await FirebaseFirestore.instance
              .collection('chatsFlutter')
              .where(
                'uuidOwner',
                isEqualTo: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid),
              )
              .where('timeBegin', isLessThan: Timestamp.fromDate(limite))
              .where('showedSeller', isEqualTo: false)
              .get();

      if (query.docs.isNotEmpty) {
        final productos =
            query.docs
                .map(
                  (doc) =>
                      (doc['RazonUser'] as String?)?.replaceFirst(
                        'Vendedor ',
                        '',
                      ) ??
                      '',
                )
                .toList();
        setState(() {
          _mostrarCuadroVendedor = true;
          _productosPendientesVendedor = productos;
          _docsPendientesVendedor = query.docs;
        });
      }
    } catch (e) {
      debugPrint('Error al revisar ventas pendientes: $e');
    }
  }

  Future<void> _marcarNoMostrarComprador() async {
    for (var doc in _docsPendientesComprador) {
      await doc.reference.update({'showed': true});
    }
    setState(() {
      _mostrarCuadroComprador = false;
    });
  }

  Future<void> _marcarNoMostrarVendedor() async {
    for (var doc in _docsPendientesVendedor) {
      await doc.reference.update({'showedSeller': true});
    }
    setState(() {
      _mostrarCuadroVendedor = false;
    });
  }

  Widget _buildCuadroPendiente({
    required String title,
    required IconData icon,
    required List<String> productos,
    required VoidCallback onCerrar,
    required VoidCallback onNoMostrar,
  }) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF00296B)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...productos.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "• $p",
                    style: const TextStyle(color: Colors.black),
                    softWrap: true,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCerrar,
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: onNoMostrar,
                    child: const Text(
                      "No mostrar nuevamente",
                      style: TextStyle(color: Color(0xFF00296B)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2;
                        onCerrar();
                      });
                    },
                    child: const Text(
                      "Ver chats",
                      style: TextStyle(color: Color(0xFF00296B)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: SizedBox(
          height: 60,
          child: Image.asset(
            "assets/images/MartekAndesAppBar.png",
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF00296B)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "MarketAndes",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Opciones",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.black),
              title: const Text("Ver favoritos"),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.black),
              title: const Text("Mapa"),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPage()),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Cerrar sesión"),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _pages),
          if (_mostrarCuadroComprador)
            _buildCuadroPendiente(
              title: "¡No dejes escapar tu compra!",
              icon: Icons.shopping_cart,
              productos: _productosPendientes,
              onCerrar: () => setState(() => _mostrarCuadroComprador = false),
              onNoMostrar: _marcarNoMostrarComprador,
            ),
          if (_mostrarCuadroVendedor)
            _buildCuadroPendiente(
              title: "¡No dejes escapar tu venta!",
              icon: Icons.store,
              productos: _productosPendientesVendedor,
              onCerrar: () => setState(() => _mostrarCuadroVendedor = false),
              onNoMostrar: _marcarNoMostrarVendedor,
            ),
        ],
      ),
      bottomNavigationBar: NavbarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
