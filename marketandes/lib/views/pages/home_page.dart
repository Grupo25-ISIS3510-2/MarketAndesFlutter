import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketandes/views/pages/product_detail_page.dart';

class Product {
  final String name;
  final int price;
  final String? imagePath;
  final String description;
  final String sellerID;
  final String uidSeller;
  final int sellerRating;
  final String category;

  Product({
    required this.name,
    required this.price,
    this.imagePath,
    required this.description,
    required this.sellerID,
    required this.sellerRating,
    required this.uidSeller,
    required this.category,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      name: data['name'],
      price: data['price'],
      imagePath: data['imageURL'],
      description: data['description'] ?? 'Sin descripción',
      sellerID: data['sellerID'] ?? 'Vendedor desconocido',
      uidSeller: data['uidSeller'] ?? 'Vendedor desconocido',
      sellerRating: data['sellerRating'] ?? 0,
      category: data['category'] ?? 'General',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> userPreferences = [];

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
  }

  Future<void> fetchUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['preferencias'] is List) {
          setState(() {
            userPreferences = List<String>.from(data['preferencias']);
          });
        }
      }
    }
  }

  Future<List<Product>> fetchRecommendedProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    List<Product> allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    
    List<Product> recommendedProducts = allProducts
        .where((product) => userPreferences.contains(product.category))
        .take(4)
        .toList();
    
    return recommendedProducts;
  }

  Future<List<Product>> fetchAllProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    List<Product> allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    return allProducts;
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
                future: fetchRecommendedProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return _buildProductGrid(snapshot.data ?? [], context);
                  }
                },
              ),
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
                future: fetchAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<Product> allProducts = snapshot.data ?? [];
                    allProducts.removeWhere((product) => userPreferences.contains(product.category));
                    return _buildProductGrid(allProducts, context);
                  }
                },
              ),
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
            builder:
                (context) => ProductDetailPage(
                  name: product.name,
                  price: product.price,
                  imagePath: product.imagePath,
                  description: product.description,
                  sellerID: product.sellerID,
                  sellerUUID: product.uidSeller,
                  sellerRating: product.sellerRating,
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
                child:
                    product.imagePath != null && product.imagePath!.isNotEmpty
                        ? Image.network(
                          product.imagePath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Colors.grey,
                            );
                          },
                        )
                        : const Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        ),
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
      ),
    );
  
}
}