import 'package:flutter/material.dart';
import '../../controllers/login_register_controller.dart';

class LoginRegisterPage extends StatelessWidget {
  const LoginRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginRegisterController();

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 90),
                child: Image.asset(
                  'assets/images/MartekAndesBanner.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      '¡Al hacer clic en "Iniciar sesión", aceptas el tratamiento de tus datos para ofrecerte una mejor experiencia!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Color(0xFF00296B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          height: 50,
                          width: constraints.maxWidth,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00296B),
                            ),
                            onPressed: () => controller.goToLogin(context),
                            child: FittedBox(
                              // <-- Añadido para que el contenido escale
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/uniAndesLogo.png',
                                    height: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "INICIAR SESIÓN CON CUENTA UNIANDES",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Mulish",
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // ✅ BOTÓN NUEVO: USUARIOS SIN CONEXIÓN
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF00296B),
                            width: 2,
                          ),
                        ),
                        onPressed:
                            () => controller.goToOfflineUsers(
                              context,
                            ), // ← crea esta función
                        child: const Text(
                          "USUARIOS SIN CONEXIÓN",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: Color(0xFF00296B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => controller.goToRegister(context),
                        child: const Text(
                          "¿Primera vez? Regístrate aquí",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: Color(0xFF00296B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
