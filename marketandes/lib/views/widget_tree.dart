import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketandes/views/pages/chat_page.dart';
import 'package:marketandes/views/pages/home_page.dart';
import 'package:marketandes/views/pages/add_page.dart';
import 'package:marketandes/views/pages/map_page.dart';
import 'package:marketandes/views/pages/login_page.dart';
import 'package:marketandes/widgets/navbar_widget.dart';

class HomeWithNavbar extends StatefulWidget {
  final int selectedIndex;

  const HomeWithNavbar({super.key, this.selectedIndex = 0});

  @override
  State<HomeWithNavbar> createState() => _HomeWithNavbarState();
}

class _HomeWithNavbarState extends State<HomeWithNavbar> {
  late int _selectedIndex;

  final List<Widget> _pages = [HomePage(), AddPage(), ChatPage()];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // Si no se pasa, usa 0 por default
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
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavbarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
