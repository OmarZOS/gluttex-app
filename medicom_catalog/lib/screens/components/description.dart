import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';

class Description extends StatelessWidget {
  const Description({super.key, required this.product});

  final Product product;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: GluttexConstants.kDefaultPaddin),
      child: Text(
        "To include a small rounded image for each product in your grid view, you can use the ClipRRect widget to create a rounded image. The ClipRRect widget allows you to clip the image into a rounded rectangle shape. Additionally, you'll need to load and display the image using an Image widget." ??
            "",
        style: TextStyle(height: 1.5),
      ),
    );
  }
}
