import 'package:flutter/material.dart';
import 'package:marketandes/data/notifiers.dart';
import 'package:marketandes/views/pages/add_page.dart';
import 'package:marketandes/views/pages/home_page.dart';
import 'package:marketandes/views/pages/start_page.dart';
import '../widgets/navbar_widget.dart';

List<Widget> pages = [HomePage(), AddPage(), StartPage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  // Índices donde SÍ hay AppBar y BottomNavBar
  final List<int> pagesWithBars = const [0, 1];

  // Tus páginas
  static final List<Widget> pages = [HomePage(), AddPage(), StartPage()];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedIndex, _) {
        bool showBars = pagesWithBars.contains(selectedIndex);

        return Scaffold(
          appBar:
              showBars
                  ? AppBar(
                    backgroundColor: const Color(0xFF00296B),
                    title: SizedBox(
                      height: 60,
                      child: Image.asset(
                        "assets/images/MartekAndesAppBar.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    centerTitle: true,
                  )
                  : null,
          body: pages[selectedIndex],
          bottomNavigationBar:
              showBars ? NavbarWidget(selectedIndex: selectedIndex) : null,
        );
      },
    );
  }
}
