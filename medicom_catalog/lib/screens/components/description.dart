import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';

class Description extends StatelessWidget {
  const Description({super.key, required this.product});

  final Product product;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GluttexConstants.kDefaultPaddin),
      child: Text(
        product.product_description ?? "",
        style: TextStyle(height: 1.5),
      ),
    );
  }
}
