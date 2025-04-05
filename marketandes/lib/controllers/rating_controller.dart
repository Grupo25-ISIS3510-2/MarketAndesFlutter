import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRating(Rating rating) async {
    final reviewCollection = _firestore.collection('shopping_reviews');
    await reviewCollection.add(rating.toMap());
  }
}
