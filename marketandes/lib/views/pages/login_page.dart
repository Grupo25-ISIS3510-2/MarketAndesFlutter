import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/login_model.dart';
import '../../controllers/login_controller.dart';
import 'login_register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginModel model = LoginModel();
  late LoginController controller;
  bool isConnected = true;
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();
    controller = LoginController(model: model, context: context);

    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;

    _checkInitialConnection();
    _listenToConnectivity();
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      isConnected = result != ConnectivityResult.none;
    });
  }

  void _listenToConnectivity() {
    _connectivityStream.listen((ConnectivityResult result) {
      final nowConnected = result != ConnectivityResult.none;
      if (nowConnected != isConnected) {
        setState(() {
          isConnected = nowConnected;
        });

        final message =
            nowConnected
                ? '✅ Has recuperado la conexión a internet'
                : '⚠️ No hay conexión a internet';
        final color = nowConnected ? Colors.green : Colors.red;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF00296B),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  height: 580.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFDFD),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/marketAndesIconLogin.png',
                          height: 200,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                          height: 350,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDFDFD),
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(30),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email",

                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: model.emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "example@uniandes.edu.co",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "Contraseña",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: model.passwordController,
                                obscureText: true,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              if (!isConnected)
                                const Text(
                                  "⚠️ No tienes conexión a internet",
                                  style: TextStyle(color: Colors.red),
                                ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      model.isLoading || !isConnected
                                          ? null
                                          : () => controller.login(
                                            () => setState(() {}),
                                          ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00296B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child:
                                      model.isLoading
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : const Text(
                                            "Iniciar sesión",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginRegisterPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
