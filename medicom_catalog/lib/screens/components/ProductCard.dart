import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:medicom_catalog/screens/product_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            product: product,
          ),
        ),
      ),
      child: Card(
        // color: Colors.blue[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                width: double
                    .infinity, // make the container take up the full width
                child: Center(
                  child: product.product_image_data != null &&
                          product.product_image_data!.isNotEmpty
                      ? Image.memory(
                          product.product_image_data!,
                          fit: BoxFit.cover, // fit the image within the space
                        )
                      : Container(
                          child: Placeholder(),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    product.product_name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // const SizedBox(height: 4),
                  Text(
                    product.product_category_desc ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.product_price ?? 'N/A'} DA',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // IconButton(
                      //   onPressed: () {
                      //     // Add to cart action
                      //   },
                      //   icon: const Icon(Icons.add_shopping_cart),
                      //   // label: const Text(GluttexConstants.addToCart),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
