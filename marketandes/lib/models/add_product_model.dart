import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketandes/controllers/session_state_controller.dart';

class AddProductModel {
  final String title;
  final String description;
  final String imageUrl;
  final int price;
  final String category;

  AddProductModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
  });

  Map<String, dynamic> toMap(String fullName, String uid) {
    return {
      'name': title.trim(),
      'description': description.trim(),
      'price': price,
      'imageURL': imageUrl.trim(),
      'category': category,
      'sellerID': fullName,
      'sellerRating': 5,
      'uidSeller': uid,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  static Future<void> submit(AddProductModel product) async {
    final uid = currentUserUuid.value;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final fullName = userDoc.data()?['fullName'] ?? "Vendedor Desconocido";

    final productsCollection = FirebaseFirestore.instance.collection('products');
    await productsCollection.add(product.toMap(fullName, uid));
  }
}
