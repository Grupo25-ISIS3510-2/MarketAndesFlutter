import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/rating_model.dart';

class RatingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _offlineBox = Hive.box('offlineUsers');

Future<bool> submitRating(Rating rating) async {
  final isConnected = await _checkConnection();

  if (isConnected) {
    await _firestore.collection('shopping_reviews').add(rating.toMap());
    return true; // enviado online
  } else {
    final List offlineRatings =
        _offlineBox.get('pendingRatings', defaultValue: []) as List;
    offlineRatings.add(rating.toMap());
    await _offlineBox.put('pendingRatings', offlineRatings);
    return false; // guardado offline
  }
}

  Future<void> retryPendingRatings() async {
    final isConnected = await _checkConnection();
    if (!isConnected) return;

    final List pendingRatings =
        _offlineBox.get('pendingRatings', defaultValue: []) as List;
    final reviewCollection = _firestore.collection('shopping_reviews');

    for (var rating in pendingRatings) {
      await reviewCollection.add(rating);
    }

    // Limpiar los pendientes
    await _offlineBox.put('pendingRatings', []);
  }

  Future<bool> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
