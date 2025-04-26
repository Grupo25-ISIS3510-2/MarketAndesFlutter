import 'package:flutter/material.dart';
import 'package:marketandes/models/product_model.dart';
import 'package:marketandes/controllers/product_controller.dart';
import 'package:marketandes/views/pages/product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController _controller = ProductController();

  @override
  void initState() {
    super.initState();
    _controller.fetchUserPreferences().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  "Recomendados",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Product>>(
                    future: _controller.fetchRecommendedProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final recommendedProducts = snapshot.data ?? [];
                        return Column(
                          children: [
                            _buildProductGrid(recommendedProducts),
                            const SizedBox(height: 20),
                            const Center(
                              child: Text(
                                "Explorar Todos los Productos",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FutureBuilder<List<Product>>(
                              future: _controller.fetchAllProducts(),
                              builder: (context, allSnapshot) {
                                if (allSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (allSnapshot.hasError) {
                                  return Text('Error: ${allSnapshot.error}');
                                } else {
                                  final allProducts = allSnapshot.data ?? [];
                                  final filteredProducts = allProducts.where((product) =>
                                    !recommendedProducts.any((recommended) => recommended.name == product.name)
                                  ).toList();

                                  return _buildProductGrid(filteredProducts);
                                }
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
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
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    // Usamos el campo `name` como identificador para verificar si el producto está en favoritos
    bool isFavorite = _controller.userFavorites.contains(product.name);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.topRight, // Alineamos el corazón en la esquina superior derecha
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: product.imagePath != null && product.imagePath!.isNotEmpty
                        ? Image.network(
                            product.imagePath!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                          )
                        : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  // Usamos el nombre del producto como identificador
                  _controller.toggleFavorite(product.name);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
