import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class ProductController {
  List<String> userPreferences = [];
  List<String> userFavorites = []; // Lista para almacenar los favoritos del usuario.

  Future<void> fetchUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // Cargar las preferencias del usuario
          if (data['preferencias'] is List) {
            userPreferences = List<String>.from(data['preferencias']);
          }
          // Cargar los favoritos del usuario
          if (data['favoritos'] is List) {
            userFavorites = List<String>.from(data['favoritos']);
          }
        }
      }
    }
  }

  Future<void> toggleFavorite(String productName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Si el producto ya está en favoritos, lo eliminamos. Si no, lo agregamos.
      if (userFavorites.contains(productName)) {
        userFavorites.remove(productName);
      } else {
        userFavorites.add(productName);
      }

      // Actualizamos la lista de favoritos en Firestore
      await docRef.update({
        'favoritos': userFavorites,
      });
    }
  }

  Future<List<Product>> fetchRecommendedProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    List<Product> allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    // Marcar los productos recomendados como favoritos si están en la lista de favoritos del usuario
    return allProducts
        .where((product) => userPreferences.contains(product.category))
        .take(4)
        .map((product) {
          product.isFavorite = userFavorites.contains(product.name); // Usamos 'name' como identificador único
          return product;
        })
        .toList();
  }

  Future<List<Product>> fetchAllProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    List<Product> allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    // Marcar todos los productos como favoritos si están en la lista de favoritos del usuario
    return allProducts.map((product) {
      product.isFavorite = userFavorites.contains(product.name); // Usamos 'name' como identificador único
      return product;
    }).toList();
  }
}
