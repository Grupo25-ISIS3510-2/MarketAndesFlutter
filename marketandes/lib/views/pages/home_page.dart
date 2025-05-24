import 'package:flutter/material.dart';
import 'package:marketandes/models/product_model.dart';
import 'package:marketandes/controllers/product_controller.dart';
import 'package:marketandes/views/pages/product_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController _controller = ProductController();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = ['Todas'];
  String _selectedCategory = 'Todas';

  @override
  void initState() {
    super.initState();
    _controller.fetchUserPreferences().then((_) {
      setState(() {});
    });

    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    final all = await _controller.fetchAllProductsWithIsolate();
    final uniqueCategories = <String>{'Todas'};
    for (var product in all) {
      if (product.category.isNotEmpty) {
        uniqueCategories.add(product.category);
      }
    }

    setState(() {
      _allProducts = all;
      _categories = uniqueCategories.toList();
      _filteredProducts = _filterProductsByCategory(_selectedCategory);
    });
  }

  List<Product> _filterProductsByCategory(String category) {
    if (category == 'Todas') return _allProducts;
    return _allProducts.where((product) => product.category == category).toList();
  }

  void _onCategoryChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedCategory = value;
      _filteredProducts = _filterProductsByCategory(_selectedCategory);
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
                    final explorarProducts = _filteredProducts.where((product) =>
                      !recommendedProducts.any((recommended) => recommended.name == product.name)).toList();

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

                        // Dropdown para seleccionar categoría
                        DropdownButton<String>(
                          value: _selectedCategory,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: _categories.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: _onCategoryChanged,
                        ),
                        const SizedBox(height: 10),

                        _buildProductGrid(explorarProducts),
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
          alignment: Alignment.topRight,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: product.imagePath != null && product.imagePath!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imagePath!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
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
