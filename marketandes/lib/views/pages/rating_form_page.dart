import 'package:flutter/material.dart';
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

  void _submitReview() async {
    try {
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
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar la calificación: $e')),
      );
    }
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
      body: Padding(
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
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFDC500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 5,
      ),
      onPressed: _submitReview,
      child: const Text(
        "Enviar Calificación",
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
