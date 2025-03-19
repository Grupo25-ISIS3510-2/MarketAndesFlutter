import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  final int selectedIndex;

  const NavbarWidget({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: const Color(0xFF00296B),
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
      selectedIndex: selectedIndex,
    );
  }
}
