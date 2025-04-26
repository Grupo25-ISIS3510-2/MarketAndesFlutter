import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final int price;
  final String? imagePath;
  final String description;
  final String sellerID;
  final String uidSeller;
  final int sellerRating;
  final String category;
  bool isFavorite; // Agregamos el campo para saber si el producto es favorito.

  Product({
    required this.name,
    required this.price,
    this.imagePath,
    required this.description,
    required this.sellerID,
    required this.sellerRating,
    required this.uidSeller,
    required this.category,
    this.isFavorite = false, // Inicializamos como no favorito por defecto.
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
      isFavorite: false, // Cuando se crea un producto desde Firestore, no tenemos el estado de favorito, lo dejamos en false por defecto.
    );
  }
}
