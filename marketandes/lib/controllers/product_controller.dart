import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class ProductController {
  List<String> userPreferences = [];

  Future<void> fetchUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['preferencias'] is List) {
          userPreferences = List<String>.from(data['preferencias']);
        }
      }
    }
  }

  Future<List<Product>> fetchRecommendedProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    List<Product> allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    return allProducts
        .where((product) => userPreferences.contains(product.category))
        .take(4)
        .toList();
  }

  Future<List<Product>> fetchAllProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    List<Product> allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    return allProducts
        .where((product) => !userPreferences.contains(product.category))
        .toList();
  }
}
