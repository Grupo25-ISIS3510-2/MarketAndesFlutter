import 'package:flutter/material.dart';
import 'package:marketandes/data/notifiers.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      selectedPageNotifier.value = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF00296B),
      child: Center(child: Image.asset("assets/images/MartekAndesLogo.png")),
    );
  }
}
