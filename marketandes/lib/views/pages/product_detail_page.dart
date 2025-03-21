import 'package:flutter/material.dart';
import 'package:marketandes/widgets/navbar_widget.dart'; // Importamos el navbar

class ProductDetailPage extends StatefulWidget {
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
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: const Text("MarketAndes", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    if (widget.imagePath != null)
                      Image.asset(widget.imagePath!, height: 200),
                    const SizedBox(height: 10),
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "\$${widget.price.toString()}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00296B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Icon(Icons.account_circle, size: 24),
                  SizedBox(width: 8),
                  Text("Manuel Herrera", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(4, (index) => const Icon(Icons.star, color: Colors.amber, size: 20))
                  ..add(const Icon(Icons.star_border, color: Colors.amber, size: 20)),
              ),
              const SizedBox(height: 20),
              const Text(
                "Bata de laboratorio oficial de la Universidad de Los Andes, diseñada para brindar comodidad y protección en prácticas y experimentos. Confeccionada en tela resistente y ligera, cuenta con un ajuste cómodo y duradero, ideal para largas jornadas en el laboratorio. Sus bolsillos amplios permiten guardar herramientas y materiales esenciales, mientras que su diseño profesional la hace perfecta tanto para estudiantes como para profesionales de ciencias.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text("Comprar", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00296B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text("Contactar Vendedor", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavbarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
