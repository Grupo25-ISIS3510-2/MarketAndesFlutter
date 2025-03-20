import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavbarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: const Color(0xFF00296B),
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemTapped,
      destinations: [
        NavigationDestination(
          icon: Image.asset("assets/images/homeIcon.png"),
          selectedIcon: Image.asset("assets/images/homeIconSelected.png"),
          label: "",
        ),
        NavigationDestination(
          icon: Image.asset("assets/images/addIcon.png"),
          selectedIcon: Image.asset("assets/images/addIconSelected.png"),
          label: "",
        ),
        // Si quieres agregar más pestañas, agrégalas aquí:
        // NavigationDestination(
        //   icon: Image.asset("assets/images/tradeIcon.png"),
        //   selectedIcon: Image.asset("assets/images/tradeIconSelected.png"),
        //   label: "",
        // ),
      ],
    );
  }
}
