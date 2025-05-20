import 'dart:async';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class ProductController {
  List<String> userPreferences = [];
  List<String> userFavorites = [];

  // Future simple con async/await
  Future<void> fetchUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
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




  Future<void> toggleFavorite(String productName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      if (userFavorites.contains(productName)) {
        userFavorites.remove(productName);
      } else {
        userFavorites.add(productName);
      }

      await docRef.update({
        'favoritos': userFavorites,
      });
    }
  }


  // Isolate para procesar productos en segundo plano
  Future<List<Product>> fetchAllProductsWithIsolate() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    final rawProducts = snapshot.docs.map((doc) => doc.data()).toList();

    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateProcessor, [receivePort.sendPort, rawProducts, userFavorites]);

    final result = await receivePort.first as List<Product>;
    return result;
  }

  static void _isolateProcessor(List<dynamic> args) {
    SendPort sendPort = args[0];
    List<Map<String, dynamic>> rawProducts = List<Map<String, dynamic>>.from(args[1]);
    List<String> favorites = List<String>.from(args[2]);

    List<Product> processed = rawProducts.map((data) {
      final product = Product.fromMap(data);
      product.isFavorite = favorites.contains(product.name);
      return product;
    }).toList();

    sendPort.send(processed);
  }

  // Future simple con async/await
  Future<List<Product>> fetchRecommendedProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    List<Product> allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    return allProducts
        .where((product) => userPreferences.contains(product.category))
        .take(4)
        .map((product) {
          product.isFavorite = userFavorites.contains(product.name);
          return product;
        })
        .toList();
  }


}
