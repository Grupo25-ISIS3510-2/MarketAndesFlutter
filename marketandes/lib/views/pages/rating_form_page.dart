import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../controllers/rating_controller.dart';
import '../../models/rating_model.dart';

class RatingFormPage extends StatefulWidget {
  const RatingFormPage({super.key});

  @override
  _RatingFormPageState createState() => _RatingFormPageState();
}

class _RatingFormPageState extends State<RatingFormPage> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();
  final RatingController _ratingController = RatingController();
  final Connectivity _connectivity = Connectivity();

  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isConnected = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      final connected = result != ConnectivityResult.none;
      if (_isConnected != connected) {
        setState(() => _isConnected = connected);
      }
      if (connected) _ratingController.retryPendingRatings();
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    commentController.dispose();
    super.dispose();
  }

  void _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    final isConnected = result != ConnectivityResult.none;
    if (_isConnected != isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  }

  void _showSnackbar(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _submitReview() async {
    if (!_isConnected) {
      _showSnackbar(
        'No hay conexión. Por favor, inténtalo cuando estés en línea.',
        color: Colors.redAccent,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final rating = Rating(
      rating: selectedRating,
      comment: commentController.text,
      timestamp: DateTime.now(),
    );

    await _ratingController.submitRating(rating);

    _showSnackbar('Calificación enviada exitosamente');

    setState(() {
      selectedRating = 0;
      commentController.clear();
      _isSubmitting = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: SizedBox(
          height: 60,
          child: Image.asset(
            "assets/images/MartekAndesAppBar.png",
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "¿Cómo fue tu experiencia?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00296B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStarRating(),
                  const SizedBox(height: 30),
                  _buildCommentBox(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          if (!_isConnected)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.redAccent,
                  child: const Text(
                    "⚠️ Sin conexión. No puedes enviar la calificación.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Wrap(
        spacing: 5.0,
        alignment: WrapAlignment.center,
        children: List.generate(5, (index) {
          return IconButton(
            tooltip: 'Calificación de ${index + 1} estrellas',
            icon: Icon(
              Icons.star,
              color: index < selectedRating ? const Color(0xFFFDC500) : Colors.grey,
              size: 40,
            ),
            onPressed: () {
              setState(() {
                selectedRating = index + 1;
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildCommentBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: commentController,
        maxLines: 8,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          hintText: "Escribe tu comentario...",
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: (_isSubmitting || !_isConnected) ? null : _submitReview,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isConnected ? const Color(0xFFFDC500) : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 5,
      ),
      child: Text(
        _isConnected ? "Enviar Calificación" : "Sin conexión",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
