import 'package:flutter/material.dart';
import '../../models/login_model.dart';
import '../../controllers/login_controller.dart';
import 'login_register.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../controllers/auth_controller.dart';

class OfflineLoginPage extends StatefulWidget {
  const OfflineLoginPage({super.key});

  @override
  State<OfflineLoginPage> createState() => _OfflineLoginPageState();
}

class _OfflineLoginPageState extends State<OfflineLoginPage> {
  Future<void> _loadLocalUsers() async {
    final box = Hive.box('offlineUsers');

    // Obtenemos los valores (mapas) y extraemos los emails
    final users =
        box.values
            .map((entry) => entry['email'] as String?)
            .whereType<String>()
            .toList();

    setState(() {
      localUsers = users;
      if (users.isNotEmpty) selectedUser = users.first;
    });
  }

  final LoginModel model = LoginModel();
  late LoginController controller;

  // Lista simulada de usuarios locales (puede estar vacía por ahora)
  List<String> localUsers = ["Juan"];
  String? selectedUser;

  @override
  void initState() {
    super.initState();
    controller = LoginController(model: model, context: context);
    _loadLocalUsers();
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
                                "Usuario local",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: selectedUser,
                                items:
                                    localUsers
                                        .map(
                                          (user) => DropdownMenuItem(
                                            value: user,
                                            child: Text(user),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedUser = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Selecciona un usuario",
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "Contraseña",
                                style: TextStyle(
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
                                  controller: model.passwordController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: "password",
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
                              const SizedBox(height: 15),
                              if (model.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    model.errorMessage!,
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
                                      model.isLoading || selectedUser == null
                                          ? null
                                          : () async {
                                            setState(() {
                                              model.isLoading = true;
                                              model.errorMessage = null;
                                            });

                                            try {
                                              await authService.value
                                                  .signInSafe(
                                                    email: selectedUser!,
                                                    password:
                                                        model
                                                            .passwordController
                                                            .text
                                                            .trim(),
                                                  );

                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/home',
                                                (_) => false,
                                              );
                                            } catch (e) {
                                              setState(() {
                                                model.errorMessage = e
                                                    .toString()
                                                    .replaceFirst(
                                                      'Exception: ',
                                                      '',
                                                    );
                                              });
                                            } finally {
                                              setState(
                                                () => model.isLoading = false,
                                              );
                                            }
                                          },
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
