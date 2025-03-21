import 'package:flutter/material.dart';
import 'package:marketandes/widgets/navbar_widget.dart';

class ProductDetailPage extends StatelessWidget {
  final String name;
  final int price;
  final String? imagePath;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.price,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: SizedBox(
          height: 60,
          child: Image.asset(
            "assets/images/MartekAndesAppBar.png",
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    if (imagePath != null)
                      Image.asset(imagePath!, height: 200),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00296B), // Azul oscuro
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "\$${price.toString()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Icon(Icons.account_circle, size: 24, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    "Manuel Herrera",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  4,
                  (index) => const Icon(Icons.star, color: Colors.amber, size: 20),
                )..add(const Icon(Icons.star_border, color: Colors.amber, size: 20)),
              ),
              const SizedBox(height: 20),
              const Text(
                "Bata de laboratorio oficial de la Universidad de Los Andes, diseñada para brindar comodidad y protección en prácticas y experimentos. Confeccionada en tela resistente y ligera, cuenta con un ajuste cómodo y duradero, ideal para largas jornadas en el laboratorio. Sus bolsillos amplios permiten guardar herramientas y materiales esenciales, mientras que su diseño profesional la hace perfecta tanto para estudiantes como para profesionales de ciencias.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Comprar",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00296B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Contactar Vendedor",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavbarWidget(
        selectedIndex: 0,
        onItemTapped: (index) {
          Navigator.pop(context);
        },
      ),
    );
  }
}
