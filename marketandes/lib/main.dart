import 'package:flutter/material.dart';
import 'package:marketandes/views/widget_tree.dart';
import 'package:marketandes/widgets/navbar_widget.dart';

void main() {
  runApp(const MyApp());
}

//stateless
//material app
// acafold
// stateless not Can refresh
// statefull Can refresh

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00296B),
          brightness: Brightness.dark,
        ),
      ),
      home: WidgetTree(),
    );
  }
}
