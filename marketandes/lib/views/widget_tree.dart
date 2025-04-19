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

class HomeWithNavbar extends StatefulWidget {
  final int selectedIndex;

  const HomeWithNavbar({super.key, this.selectedIndex = 0});

  @override
  State<HomeWithNavbar> createState() => _HomeWithNavbarState();
}

class _HomeWithNavbarState extends State<HomeWithNavbar> {
  late int _selectedIndex;
  bool _mostrarCuadro = false;
  List<String> _productosPendientes = [];

  final List<Widget> _pages = [HomePage(), AddPage(), ChatPage()];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _revisarComprasPendientes();
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
      final now = DateTime.now();
      final limite = now.subtract(const Duration(days: 5));

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
            query.docs.map((doc) {
              final razon = doc['Razon'] as String? ?? '';
              return razon.replaceFirst('Comprador ', '');
            }).toList();

        setState(() {
          _mostrarCuadro = true;
          _productosPendientes = productos;
        });

        for (var doc in query.docs) {
          await doc.reference.update({'showed': true});
        }
      }
    } catch (e) {
      debugPrint('Error al revisar compras pendientes: $e');
    }
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
              leading: const Icon(Icons.map, color: Colors.black),
              title: const Text("Mapa"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
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
          if (_mostrarCuadro)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.shopping_cart, color: Color(0xFF00296B)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "¿Te olvidaste de terminar la compra de los siguientes productos?",
                              style: TextStyle(
                                color: Color(0xFF00296B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._productosPendientes.map(
                        (producto) => Text(
                          "• $producto",
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _mostrarCuadro = false;
                              });
                            },
                            child: const Text(
                              "Cerrar",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedIndex = 2;
                                _mostrarCuadro = false;
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
