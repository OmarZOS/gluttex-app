import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int categoryId = product.product_category_id ?? 0;
    // log("Card id_product: ${product.id_product}");
    return Card(
      // color: GluttexConstants().getCardColor(
      //     categoryId - 1, Theme.of(context).brightness == Brightness.dark),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Add a slight delay to allow the scale animation to complete
          Future.delayed(const Duration(milliseconds: 150), () {
            Navigator.pushNamed(context, AppRoutes.productDetails,
                arguments: {"product": product});
          });
        },
        borderRadius: BorderRadius.circular(12),
        // splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
        // highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🟢 Image takes all available space
            Expanded(
              child: Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: product.product_image_url != null
                      ? Hero(
                          tag: 'product-image-${product.id_product}-card',
                          child: Image.network(
                            product.product_image_url!,
                            key: ValueKey(product.id_product_image),
                            fit: BoxFit
                                .contain, // or BoxFit.scaleDown based on preference
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackImage(context, categoryId);
                            },
                          ),
                        )
                      : _buildPlaceholder(context),
                ),
              ),
            ),

            // 🔵 Text section: let it size naturally without expanding
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // avoid extra vertical space
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                    child: Text(
                      product.product_name ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    avatar: SvgPicture.asset(
                      'assets/icons/${product.product_category_id}.svg',
                      package: "product_catalog",
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(AppLocalizations.of(context)!
                        .productCategoryTextList
                        .split(",")[(product.product_category_id ?? 1) - 1]),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 8),
                  SizedBox(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .price(product.product_price ?? '--'),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),

                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                        // IconButton(
                        //   icon:
                        //   onPressed: () {},
                        //   padding: EdgeInsets.zero,
                        //   constraints: const BoxConstraints(),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage(BuildContext context, int categoryId) {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.3),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/$categoryId.svg',
          package: "product_catalog",
          width: 40,
          height: 40,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }
}
