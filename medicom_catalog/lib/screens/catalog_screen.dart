import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/ProductService.dart';
import 'package:locator/locator.dart';
import 'package:medicom_catalog/screens/cart_screen.dart';
import 'package:medicom_catalog/screens/components/item_card.dart';
import 'package:medicom_catalog/screens/product_screen.dart';
import 'package:badges/badges.dart' as badges;

import 'dart:developer' as developer;

class CatalogScreen extends StatelessWidget {
  final ProductService productService = Locator.get<ProductService>();

  final bool isRightToLeft; // Boolean property to determine text direction

  CatalogScreen({Key? key, required this.isRightToLeft}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () {},
          ),
          SizedBox(width: GluttexConstants.kDefaultPaddin / 2)
        ],
      ),
      floatingActionButton: badges.Badge(
          position: badges.BadgePosition.topStart(),
          badgeContent: Text(
            '3', // Replace with your dynamic number
            style: TextStyle(color: Colors.white),
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CartScreen()));
            },
            child: const Icon(Icons.shopping_cart),
          )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //       horizontal: GluttexConstants.kDefaultPaddin),
          //   child: Text(
          //     "Women",
          //     style: Theme.of(context)
          //         .textTheme
          //         .titleLarge!
          //         .copyWith(fontWeight: FontWeight.bold),
          //   ),
          // ),
          // Categories(),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: GluttexConstants.kDefaultPaddin),
                child: FutureBuilder(
                    future: productService.getAllProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError || snapshot.data!.length == 0) {
                          return Center(
                              child: Text(
                                  'Error: ${snapshot.error ?? GluttexConstants.noProductsFound}'));
                        }
                        if (snapshot.data == null) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return GridView.builder(
                          itemCount: snapshot.data!.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: GluttexConstants.kDefaultPaddin,
                            crossAxisSpacing: GluttexConstants.kDefaultPaddin,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) => ProductCard(
                            product: snapshot.data![index],
                            // press: () => Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => DetailsScreen(
                            //       product: snapshot.data![index],
                            //     ),
                            //   ),
                            // ),
                          ),
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    })),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Map product productName to icon
    // IconData iconData = _getIconForproductName(product.product_category_desc);

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
          color: Colors.blue[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Center(child: Image.asset("assets/images/bag_1.png")),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.product_name ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.product_category_desc ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${100}',
                          style: TextStyle(
                              // color: Colors.yellowAccent,
                              fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            // Add to cart action
                          },
                          icon: Icon(Icons.add_shopping_cart),
                          label: Text(GluttexConstants.addToCart),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  // Method to map product productName to icon
  IconData _getIconForproductName(String productName) {
    switch (productName) {
      case 'Diagnostic Equipment':
        return Icons
            .medical_services; // Example icon, replace with your desired icon
      case 'Surgical Instruments':
        return Icons
            .medical_services; // Example icon, replace with your desired icon
      // Add more cases for other categories
      default:
        return Icons.shopping_cart; // Default icon for unknown categories
    }
  }
}
