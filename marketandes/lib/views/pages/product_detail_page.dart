import 'package:flutter/material.dart';
import 'package:marketandes/models/product_model.dart';
import 'package:marketandes/widgets/navbar_widget.dart';
import 'package:marketandes/views/pages/rating_form_page.dart';
import 'package:marketandes/controllers/product_detail_controller.dart';
import 'package:marketandes/views/pages/chat_page.dart';
import 'package:marketandes/views/widget_tree.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final ProductDetailController controller = ProductDetailController();

  ProductDetailPage({super.key, required this.product});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (product.imagePath != null)
              Image.network(product.imagePath!, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00296B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {},
              child: Text(
                "\$${product.price}",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.account_circle, size: 24, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  product.sellerID,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                product.sellerRating,
                (index) => const Icon(Icons.star, color: Colors.amber, size: 20),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.description,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDC500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      await controller.logInteractionIfShortSession();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RatingFormPage()),
                      );
                    },
                    child: const Text("Comprar", style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00296B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      await controller.logInteractionIfShortSession();
                      await controller.createChat(
                        name: product.name,
                        sellerID: product.sellerID,
                        sellerUUID: product.uidSeller,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeWithNavbar(selectedIndex: 2)),
                      );
                    },
                    child: const Text("Contactar Vendedor", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavbarWidget(
        selectedIndex: 0,
        onItemTapped: (index) {
          Navigator.pop(context);
        },
      ),
    );
  }
}
