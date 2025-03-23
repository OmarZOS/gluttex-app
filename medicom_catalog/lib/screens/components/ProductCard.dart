import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:medicom_catalog/screens/product_screen.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // log('${product.id_product_image}');

    // if (product.id_product_image != null &&
    //     product.id_product_image != 0 &&
    //     product.product_image_url == null) {
    //   Provider.of<ProductNotifier>(context, listen: false)
    //       .getProductImage(product);
    // }
    log(GluttexConstants.fsBaseUrl + product.product_image_url!);
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
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: product.product_image_url != null
                        ? Image.network(
                            GluttexConstants.fsBaseUrl +
                                product.product_image_url!,
                            fit: BoxFit.cover,
                            key: ValueKey(product.id_product_image),
                          )
                        : Container(
                            key: const ValueKey('placeholder'),
                            child: const Placeholder(),
                          ),
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
                    AppLocalizations.of(context)!
                        .productCategoryTextList
                        .split(",")[(product.product_category_id ?? 1) - 1],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .price(product.product_price ?? '--'),
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
