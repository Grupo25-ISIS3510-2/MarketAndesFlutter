import 'package:flutter/material.dart';
import 'package:marketandes/data/notifiers.dart';

class LoginRegisterPage extends StatelessWidget {
  const LoginRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      fontFamily: "Popins",
                      color: Color(0xFF00296B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00296B),
                      ),
                      onPressed: () {
                        selectedPageNotifier.value = 3;
                      },
                      child: Row(
                        children: [
                          Image.asset('assets/images/uniAndesLogo.png'),
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
                      onPressed: () {},
                      child: Text(
                        "¿Primera vez? Registrate aquí",
                        style: TextStyle(
                          fontFamily: "Popins",
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
    );
  }
}
