import 'package:flutter/material.dart';
import 'package:marketandes/models/product_model.dart';
import 'package:marketandes/controllers/product_controller.dart';
import 'package:marketandes/views/pages/product_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController _controller = ProductController();
  String _selectedCategory = 'Todas';
  List<String> _categories = ['Todas'];

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromLocal().then((loaded) {
      if (!loaded) {
        _fetchCategories();
      }
    });
    _controller.fetchUserPreferences().then((_) {
      setState(() {});
    });
  }

  // Cargar categorías desde SharedPreferences
  Future<bool> _loadCategoriesFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList('categories');
    if (categories != null && categories.isNotEmpty) {
      setState(() {
        _categories = categories;
      });
      return true;
    }
    return false;
  }

  // Guardar categorías en SharedPreferences
  Future<void> _saveCategoriesToLocal(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', categories);
  }

  Future<void> _fetchCategories() async {
    final recommendedProducts = await _controller.fetchRecommendedProducts();
    final recommendedCategories = recommendedProducts.map((p) => p.category).toSet();

    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    final categorySet = <String>{};

    for (var doc in snapshot.docs) {
      final category = doc['category'];
      if (category != null && !recommendedCategories.contains(category)) {
        categorySet.add(category.toString());
      }
    }

    final categoriesList = ['Todas', ...categorySet.toList()];

    setState(() {
      _categories = categoriesList;
    });

    await _saveCategoriesToLocal(categoriesList);
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
                        _buildCategoryDropdown(),
                        const SizedBox(height: 10),
                        FutureBuilder<List<Product>>(
                          future: _controller.fetchAllProductsWithIsolate(),
                          builder: (context, allSnapshot) {
                            if (allSnapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (allSnapshot.hasError) {
                              return Text('Error: ${allSnapshot.error}');
                            } else {
                              final allProducts = allSnapshot.data ?? [];
                              final filteredProducts = allProducts
                                  .where((product) =>
                                      !recommendedProducts.any((recommended) => recommended.name == product.name))
                                  .where((product) =>
                                      _selectedCategory == 'Todas' || product.category == _selectedCategory)
                                  .toList();

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

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
        decoration: const InputDecoration.collapsed(hintText: ''),
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCategory = value;
            });
          }
        },
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(
              category,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
          );
        }).toList(),
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
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
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
