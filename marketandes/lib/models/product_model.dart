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
      price: (data['price'] as num).toInt(),
      imagePath: data['imageURL'],
      description: data['description'] ?? 'Sin descripción',
      sellerID: data['sellerID'] ?? 'Vendedor desconocido',
      uidSeller: data['uidSeller'] ?? 'Vendedor desconocido',
      sellerRating: data['sellerRating'] ?? 0,
      category: data['category'] ?? 'General',
      isFavorite: false, // Cuando se crea un producto desde Firestore, no tenemos el estado de favorito, lo dejamos en false por defecto.
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? 'Producto sin nombre',
      price: (map['price'] as num?)?.toInt() ?? 0,
      imagePath: map['imageURL'],
      description: map['description'] ?? 'Sin descripción',
      sellerID: map['sellerID'] ?? 'Vendedor desconocido',
      uidSeller: map['uidSeller'] ?? 'Vendedor desconocido',
      sellerRating: (map['sellerRating'] as num?)?.toInt() ?? 0,
      category: map['category'] ?? 'General',
      isFavorite: false, // Se sobrescribe luego si es necesario
    );
  }

  // Nuevo método agregado para serializar el producto a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageURL': imagePath,
      'description': description,
      'sellerID': sellerID,
      'uidSeller': uidSeller,
      'sellerRating': sellerRating,
      'category': category,
      'isFavorite': isFavorite,
    };
  }
}
