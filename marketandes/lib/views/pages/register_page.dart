import 'package:flutter/material.dart';
import 'package:marketandes/controllers/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterController controller = RegisterController();
  bool isLoading = false;
  String? errorMessage;

  void _toggleLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void _setError(String? msg) {
    setState(() {
      errorMessage = msg;
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
                  height: 700.0,
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
                          height: 450,
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
                              _buildTextField(
                                "Email",
                                controller.emailController,
                                "example@uniandes.edu.co",
                                false,
                                maxLegth: 40,
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                "Contraseña",
                                controller.passwordController,
                                "password",
                                true,
                                maxLegth: 30,
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                "Nombre",
                                controller.fullNameController,
                                "nombre y apellido",
                                false,
                                maxLegth: 60,
                              ),
                              const SizedBox(height: 15),
                              if (errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00296B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed:
                                      isLoading
                                          ? null
                                          : () {
                                            controller.register(
                                              context,
                                              _toggleLoading,
                                              _setError,
                                            );
                                          },
                                  child:
                                      isLoading
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : const Text(
                                            "Registrarte",
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
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    bool obscure, {
    int? maxLegth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            maxLength: maxLegth,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
