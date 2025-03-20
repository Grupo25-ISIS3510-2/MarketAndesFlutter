import 'package:flutter/material.dart';
import 'package:marketandes/views/pages/add_page.dart';
import 'package:marketandes/views/pages/home_page.dart';
import 'package:marketandes/views/pages/login_page.dart';
import 'package:marketandes/views/pages/login_register.dart';
import 'package:marketandes/views/pages/start_page.dart';
import 'package:marketandes/views/widget_tree.dart'; // Nuevo archivo opcional

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00296B),
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const LoginRegisterPage(),
        '/home':
            (context) =>
                const HomeWithNavbar(), // Esta es la que tiene el navbar
        '/add':
            (context) =>
                const AddPage(), // Si quieres abrir add_page sin navbar
      },
    );
  }
}
