import 'dart:async';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class ProductController {
  List<String> userPreferences = [];
  List<String> userFavorites = [];

  /// Obtiene las preferencias y favoritos del usuario actual desde Firestore.
  Future<void> fetchUserPreferences() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          if (data['preferencias'] is List) {
            userPreferences = List<String>.from(data['preferencias']);
          }
          if (data['favoritos'] is List) {
            userFavorites = List<String>.from(data['favoritos']);
          }
        }
      }
    }
  }

  /// Cambia el estado favorito de un producto y actualiza Firestore.
  Future<void> toggleFavorite(String productName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      if (userFavorites.contains(productName)) {
        userFavorites.remove(productName);
      } else {
        userFavorites.add(productName);
      }

      await userDocRef.update({
        'favoritos': userFavorites,
      });
    }
  }

  /// Obtiene todos los productos procesándolos en un isolate para no bloquear UI.
  Future<List<Product>> fetchAllProductsWithIsolate() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    final rawProducts = snapshot.docs.map((doc) => doc.data()).toList();

    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateProcessor, [receivePort.sendPort, rawProducts, userFavorites]);

    final List<Product> processedProducts = await receivePort.first as List<Product>;
    return processedProducts;
  }

  static void _isolateProcessor(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final List<Map<String, dynamic>> rawProducts = List<Map<String, dynamic>>.from(args[1]);
    final List<String> favorites = List<String>.from(args[2]);

    final List<Product> processed = rawProducts.map((data) {
      final product = Product.fromMap(data);
      product.isFavorite = favorites.contains(product.name);
      return product;
    }).toList();

    sendPort.send(processed);
  }

  /// Retorna una lista filtrada de productos recomendados según preferencias del usuario.
  Future<List<Product>> fetchRecommendedProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    final allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    final recommended = allProducts
        .where((product) => userPreferences.contains(product.category))
        .take(4)
        .map((product) {
          product.isFavorite = userFavorites.contains(product.name);
          return product;
        })
        .toList();

    return recommended;
  }
}
