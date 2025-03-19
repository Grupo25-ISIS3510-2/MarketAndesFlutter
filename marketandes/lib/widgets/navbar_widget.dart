import 'package:flutter/material.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({super.key});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Color(0xFF00296B),
      destinations: [
        NavigationDestination(
          icon: Image.asset("assets/images/cartIcon.png"),
          selectedIcon: Image.asset("assets/images/cartIconSelected.png"),
          label: "",
        ),
        NavigationDestination(
          icon: Image.asset("assets/images/addIcon.png"),
          selectedIcon: Image.asset("assets/images/addIconSelected.png"),
          label: "",
        ),
        NavigationDestination(
          icon: Image.asset("assets/images/homeIcon.png"),
          selectedIcon: Image.asset("assets/images/homeIconSelected.png"),
          label: "",
        ),
        NavigationDestination(
          icon: Image.asset("assets/images/tradeIcon.png"),
          selectedIcon: Image.asset("assets/images/tradeIconSelected.png"),
          label: "",
        ),
        NavigationDestination(
          icon: Image.asset("assets/images/chatIcon.png"),
          selectedIcon: Image.asset("assets/images/chatIconSelected.png"),
          label: "",
        ),
      ],
      onDestinationSelected: (int value) {
        setState(() {
          selectedIndex = value;
        });
      },
      selectedIndex: selectedIndex,
    );
  }
}
