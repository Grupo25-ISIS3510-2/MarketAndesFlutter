import 'package:flutter/material.dart';
import 'package:marketandes/models/add_product_model.dart';
import 'package:marketandes/views/pages/home_page.dart';
import 'package:marketandes/views/widget_tree.dart';

class AddProductController {
  final BuildContext context;
  final VoidCallback refreshUI;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController imageUrlController;

  bool isSubmitting = false;
  String? selectedCategory;

  AddProductController({
    required this.context,
    required this.refreshUI,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.imageUrlController,
  });

  Future<void> submitProduct() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        imageUrlController.text.isEmpty ||
        selectedCategory == null) {
      _showMessage("Por favor completa todos los campos");
      return;
    }

    int? price = int.tryParse(priceController.text);
    if (price == null) {
      _showMessage("El precio debe ser un número válido");
      return;
    }

    isSubmitting = true;
    refreshUI();

    try {
      final product = AddProductModel(
        title: titleController.text,
        description: descriptionController.text,
        imageUrl: imageUrlController.text,
        price: price,
        category: selectedCategory!,
      );

      await AddProductModel.submit(product);

      _showMessage("Producto publicado exitosamente");
      _navigateToHome();
    } catch (e) {
      _showMessage("Error al publicar el producto: $e");
    } finally {
      isSubmitting = false;
      refreshUI();
    }
  }

  void cancel() {
    _navigateToHome();
  }

  void setCategory(String? value) {
    selectedCategory = value;
    refreshUI();
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeWithNavbar()),
      (_) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
