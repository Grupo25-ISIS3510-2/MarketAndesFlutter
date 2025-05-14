import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marketandes/controllers/add_product_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late AddProductController controller;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final imageUrlController = TextEditingController();

  final categories = [
    "Arte",
    "Física",
    "Utensilios",
    "Diseño",
    "Lenguas",
    "Ingeniería",
    "Libros",
    "Medicina",
    "Tecnología",
    "Administración",
    "Software",
    "Música",
    "Arquitectura",
    "Psicología",
    "Educación",
    "Química",
    "Economía",
    "Comunicación",
    "Derecho",
    "Inglés",
  ];

  bool hasInternet = true;
  bool showConnectionRestoredMessage = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    controller = AddProductController(
      context: context,
      refreshUI: () => setState(() {}),
      titleController: titleController,
      descriptionController: descriptionController,
      priceController: priceController,
      imageUrlController: imageUrlController,
    );

    _checkInitialConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      final connected = result != ConnectivityResult.none;
      if (connected != hasInternet) {
        setState(() {
          hasInternet = connected;

          if (connected) {
            showConnectionRestoredMessage = true;
            Future.delayed(const Duration(seconds: 10), () {
              if (mounted) {
                setState(() {
                  showConnectionRestoredMessage = false;
                });
              }
            });
          }
        });
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      hasInternet = result != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: const Text(
          "Vender o intercambiar productos",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Título del producto"),
            _buildTextField(titleController, "Ejemplo: Bata de laboratorio"),

            const SizedBox(height: 20),
            _buildLabel("Adjunta el URL de las imágenes del producto"),
            _buildTextField(
              imageUrlController,
              "Pega aquí el enlace de la imagen",
            ),

            const SizedBox(height: 20),
            _buildLabel("Descripción corta del producto"),
            _buildTextField(
              descriptionController,
              "Escribe aquí la descripción...",
              maxLines: 5,
            ),

            const SizedBox(height: 20),
            _buildLabel("Precio del producto"),
            _buildTextField(
              priceController,
              "Ingresa el precio",
              keyboardType: TextInputType.number,
              prefixText: "\$ ",
            ),

            const SizedBox(height: 20),
            _buildLabel("Categoría del producto"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: controller.selectedCategory,
                hint: const Text("Selecciona una categoría"),
                decoration: const InputDecoration(border: InputBorder.none),
                items:
                    categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: controller.setCategory,
              ),
            ),

            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDC500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed:
                        (!hasInternet || controller.isSubmitting)
                            ? null
                            : controller.submitProduct,
                    child:
                        controller.isSubmitting
                            ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                            : const Text(
                              "Publicar",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00296B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: controller.cancel,
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (!hasInternet || showConnectionRestoredMessage)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color:
                      hasInternet ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasInternet ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  hasInternet
                      ? "Conexión restaurada. Ya puedes publicar."
                      : "Sin conexión a internet. No puedes publicar por ahora.",
                  style: TextStyle(
                    color:
                        hasInternet
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
    String prefixText = "",
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          prefixText: prefixText,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 65, 64, 64),
      ),
    );
  }
}
