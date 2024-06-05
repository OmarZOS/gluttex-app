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
          const SizedBox(height: GluttexConstants.kDefaultPaddin * 1.2),
          Text(
            product.product_brand ?? "",
            // style: const TextStyle(color: Colors.white),
          ),
          Text(
            product.product_name ?? "",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                // color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          Row(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(text: "${GluttexConstants.priceText}\n"),
                    TextSpan(
                      text: "${product.product_price} DA",
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                              // color: Colors.white,
                              fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GluttexConstants.kDefaultPaddin),
              Expanded(
                child: Hero(
                    tag: "${product.id_product}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          100), // Adjust the radius as needed
                      child: product.product_image_data != null &&
                              product.product_image_data!.isNotEmpty
                          ? Image.memory(
                              width: 156, // Adjust the size as needed
                              height: 156, // Adjust the size as needed
                              product.product_image_data!,
                              // fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }
}
