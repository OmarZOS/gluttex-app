import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.product, required this.press});

  final Product product;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(GluttexConstants.kDefaultPaddin),
              decoration: BoxDecoration(
                // color: product.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Hero(
                tag: "${product.id_product}",
                child: Image.asset(
                  "bag_1.png",
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: GluttexConstants.kDefaultPaddin / 4),
            child: Text(
              // products is out demo list
              product.product_name ?? "",
              style: TextStyle(color: GluttexConstants.kTextLightColor),
            ),
          ),
          Text(
            "\$${product.product_category_desc}",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
