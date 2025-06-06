import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketandes/views/pages/add_page.dart';
import 'package:marketandes/views/pages/home_page.dart';
import 'package:marketandes/views/pages/login_page.dart';
import 'package:marketandes/views/pages/login_register.dart';
import 'package:marketandes/views/pages/register_page.dart';
import 'package:marketandes/views/pages/start_page.dart';
import 'package:marketandes/views/widget_tree.dart';
import 'firebase_options.dart';
import 'package:marketandes/views/pages/preferences_page.dart';
import 'package:marketandes/views/pages/offline_login.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('offlineUsers');
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
        '/register': (context) => const RegisterPage(),
        '/init': (context) => const LoginRegisterPage(),
        '/home': (context) => const HomeWithNavbar(),
        '/add': (context) => const AddPage(),
        '/preferences': (context) => const PreferenciasScreen(),
        '/offlineLogin': (context) => const OfflineLoginPage(),
      },
    );
  }
}
