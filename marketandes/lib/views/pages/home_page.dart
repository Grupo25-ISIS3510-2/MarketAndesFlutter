import 'package:flutter/material.dart';
import 'package:marketandes/views/pages/product_detail_page.dart';

class Product {
  final String name;
  final int price;
  final String? imagePath;

  Product({
    required this.name,
    required this.price,
    this.imagePath,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Product> recentlyViewed = [
      Product(name: "Calculadora Ti Nspire", price: 400000, imagePath: "assets/images/calculadora.png"),
      Product(name: "Libro Cálculo Stewart", price: 50000, imagePath: "assets/images/calculo.jpg"),
    ];

    final List<Product> recommended = [
      Product(name: "Bata de laboratorio", price: 60000, imagePath: "assets/images/bata.png"),
      Product(name: "Libro Electromagnetismo", price: 40000, imagePath: "assets/images/libroelectro.jpg"),
      Product(name: "Computador Portátil Lenovo", price: 2500000, imagePath: "assets/images/pc.png"),
      Product(name: "Libro Cálculo Stewart", price: 50000, imagePath: "assets/images/calculo.jpg"),
      Product(name: "Libreta en cuero", price: 20000, imagePath: "assets/images/libreta.png"),
      Product(name: "Calculadora", price: 60000, imagePath: "assets/images/calculadora.png"),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFD8D8D8),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Visto recientemente",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              _buildProductGrid(recentlyViewed, context),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Recomendados",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              _buildProductGrid(recommended, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products, BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 4,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(context, products[index]);
      },
    );
  }

Widget _buildProductCard(BuildContext context, Product product) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(
            name: product.name,
            price: product.price,
            imagePath: product.imagePath,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: product.imagePath != null && product.imagePath!.isNotEmpty
                  ? Image.asset(
                      product.imagePath!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                      },
                    )
                  : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black, fontFamily: 'Poppins'),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF00296B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                "\$ ${product.price}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
