import 'package:flutter/material.dart';

class LoginRegisterPage extends StatelessWidget {
  const LoginRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      '¡Al hacer clic en "Iniciar sesión", aceptas el tratamiento de tus datos para ofrecerte una mejor experiencia!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Color(0xFF00296B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00296B),
                        ),
                        onPressed: () {
                          // Navega al login page
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/uniAndesLogo.png',
                              height: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
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
                    SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Navega a la página de registro
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
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
