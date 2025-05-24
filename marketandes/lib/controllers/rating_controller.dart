import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/rating_model.dart';

class RatingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _offlineBox = Hive.box('offlineUsers');

  /// Envía la calificación. Si no hay conexión, la guarda localmente.
  Future<bool> submitRating(Rating rating) async {
    final bool isConnected = await _checkConnection();

    if (isConnected) {
      await _firestore.collection('shopping_reviews').add(rating.toMap());
      return true; // enviado online
    } else {
      final List offlineRatings = _offlineBox.get('pendingRatings', defaultValue: []) as List;
      offlineRatings.add(rating.toMap());
      await _offlineBox.put('pendingRatings', offlineRatings);
      return false; // guardado offline
    }
  }

  /// Reintenta enviar las calificaciones pendientes almacenadas localmente.
  Future<void> retryPendingRatings() async {
    final bool isConnected = await _checkConnection();
    if (!isConnected) return;

    final List pendingRatings = _offlineBox.get('pendingRatings', defaultValue: []) as List;
    final CollectionReference reviewCollection = _firestore.collection('shopping_reviews');

    try {
      for (final rating in pendingRatings) {
        await reviewCollection.add(rating);
      }
      // Limpia los pendientes tras enviar con éxito
      await _offlineBox.put('pendingRatings', []);
    } catch (e) {
      // Aquí se puede agregar logging o manejo de error si se desea
    }
  }

  /// Verifica si el dispositivo tiene conexión a internet.
  Future<bool> _checkConnection() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
