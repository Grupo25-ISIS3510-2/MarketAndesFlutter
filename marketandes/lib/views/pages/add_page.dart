import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketandes/data/notifiers.dart';
import 'package:marketandes/views/widget_tree.dart';
import 'package:marketandes/views/pages/home_page.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  bool _isSubmitting = false;
  String? selectedCategory;

  final List<String> categories = [
    "Arte", "Física", "Utensilios", "Diseño", "Lenguas", "Ingeniería",
    "Libros", "Medicina", "Tecnología", "Administración", "Software",
    "Música", "Arquitectura", "Psicología", "Educación", "Química",
    "Economía", "Comunicación", "Derecho", "Inglés"
  ];

  void _submitProduct() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        imageUrlController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
      return;
    }

    int? price = int.tryParse(priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El precio debe ser un número válido")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uid = currentUserUuid.value;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final fullName = userDoc.data()?['fullName'] ?? "Vendedor Desconocido";

      final productsCollection = FirebaseFirestore.instance.collection('products');
      final productData = {
        'name': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': price,
        'imageURL': imageUrlController.text.trim(),
        'category': selectedCategory,
        'sellerID': fullName,
        'sellerRating': 5,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await productsCollection.add(productData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto publicado exitosamente')),
      );

      _navigateToHome();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar el producto: $e')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeWithNavbar()),
      (Route<dynamic> route) => false,
    );
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
            _buildTextField(imageUrlController, "Pega aquí el enlace de la imagen"),

            const SizedBox(height: 20),
            _buildLabel("Descripción corta del producto"),
            _buildTextField(descriptionController, "Escribe aquí la descripción...", maxLines: 5),

            const SizedBox(height: 20),
            _buildLabel("Precio del producto"),
            _buildTextField(priceController, "Ingresa el precio", keyboardType: TextInputType.number, prefixText: "\$ "),

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
                value: selectedCategory,
                hint: const Text("Selecciona una categoría"),
                decoration: const InputDecoration(border: InputBorder.none),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDC500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isSubmitting ? null : _submitProduct,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Publicar",
                            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00296B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _navigateToHome,
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {TextInputType keyboardType = TextInputType.text, String prefixText = "", int maxLines = 1}) {
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 65, 64, 64)),
    );
  }
}
