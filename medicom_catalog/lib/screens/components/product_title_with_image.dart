import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';

class ProductTitleWithImage extends StatelessWidget {
  const ProductTitleWithImage({super.key, required this.product});

  final Product product;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: GluttexConstants.kDefaultPaddin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: GluttexConstants.kDefaultPaddin * 1.2),
          Text(
            product.product_brand ?? "",
            style: TextStyle(color: Colors.white),
          ),
          Text(
            product.product_name ?? "",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Row(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "Price\n"),
                    TextSpan(
                      text: "\$${product.product_barcode}",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(width: GluttexConstants.kDefaultPaddin),
              Expanded(
                child: Hero(
                    tag: "${product.id_product}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          100), // Adjust the radius as needed
                      child: Image.network(
                        "https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                        width: 156, // Adjust the size as needed
                        height: 156, // Adjust the size as needed
                        fit: BoxFit.cover,
                      ),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }
}
