import 'package:flutter/material.dart';
import 'package:marketandes/data/notifiers.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo azul con el contenido
          Container(
            color: const Color(0xFF00296B),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  height: 525.0,
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
                          height: 290,
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
                              Text(
                                "Email",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  style: TextStyle(color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: "example@uniandes.edu.co",
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                "Contraseña",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  style: TextStyle(color: Colors.black87),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: "password",
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00296B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    "Iniciar sesión",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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

          // Botón de retroceso arriba a la izquierda
          Positioned(
            top: 40, // margen superior (ajústalo según necesites)
            left: 20, // margen izquierdo
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                selectedPageNotifier.value = 4;
              },
            ),
          ),
        ],
      ),
    );
  }
}
