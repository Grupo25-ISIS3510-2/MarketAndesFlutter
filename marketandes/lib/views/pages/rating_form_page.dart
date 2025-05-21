import 'package:flutter/material.dart';
import '../../controllers/rating_controller.dart';
import '../../models/rating_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RatingFormPage extends StatefulWidget {
  const RatingFormPage({super.key});

  @override
  _RatingFormPageState createState() => _RatingFormPageState();
}

class _RatingFormPageState extends State<RatingFormPage> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();
  final RatingController _ratingController = RatingController();
  bool _isConnected = true;
  bool _isSubmitting = false;
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();

    _connectivity = Connectivity();

    _checkInitialConnection();

    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });

      if (_isConnected) {
        _ratingController.retryPendingRatings();
      }
    });
  }

  void _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  void _submitReview() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay conexión. Por favor, inténtalo cuando estés en línea.'),
          backgroundColor: Colors.redAccent,
        ),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calificación enviada exitosamente')),
    );

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
          Padding(
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
                    "⚠️ Sin conexión. Tu calificación se enviará cuando se recupere la conexión.",
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
