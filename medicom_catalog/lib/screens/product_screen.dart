import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/ProductService.dart';
import 'package:locator/locator.dart';
import 'package:medicom_catalog/screens/cart_screen.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:medicom_catalog/screens/components/add_to_cart.dart';
import 'package:medicom_catalog/screens/components/color_and_size.dart';
import 'package:medicom_catalog/screens/components/counter_with_fav_btn.dart';
import 'package:medicom_catalog/screens/components/description.dart';
import 'package:medicom_catalog/screens/components/product_title_with_image.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      // each product have a color
      backgroundColor: Colors.blue,
      appBar: AppBar(
        // backgroundColor: product.color,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: size.height,
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.3),
                    padding: EdgeInsets.only(
                      top: size.height * 0.12,
                      left: GluttexConstants.kDefaultPaddin,
                      right: GluttexConstants.kDefaultPaddin,
                    ),
                    // height: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        ColorAndSize(product: product),
                        SizedBox(height: GluttexConstants.kDefaultPaddin / 2),
                        Description(product: product),
                        SizedBox(height: GluttexConstants.kDefaultPaddin / 2),
                        CounterWithFavBtn(),
                        SizedBox(height: GluttexConstants.kDefaultPaddin / 2),
                        AddToCart(product: product)
                      ],
                    ),
                  ),
                  ProductTitleWithImage(product: product)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



// void showProductDetails(BuildContext context, Product product) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('${product.product_name}'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
            // Flexible(
            //   child: InfiniteCarousel.builder(
            //     itemCount: 1,
            //     itemExtent: 200,
            //     center: true,
            //     // anchor: 0.0,
            //     velocityFactor: 0.3,
            //     onIndexChanged: (index) {},
            //     // controller: controller,
            //     axisDirection: Axis.horizontal,
            //     loop: true,
            //     itemBuilder: (context, itemIndex, realIndex) {
            //       return Center(
            //           child: Image.network(
            //               "https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"));
            //     },
            //   ),
            // ),
//             Text('Product Name: ${product.product_name}'),
//             Text('Product Category: ${product.product_category_desc}'),
//             Text('Product Brand: ${product.product_brand}'),
//             Text('Product Barcode: ${product.product_barcode}'),
//           ],
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: Text('Cancel'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text('Buy'),
//             onPressed: () {
//               Navigator.of(context).pop();
//               _buyProduct(context, product);
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// void _buyProduct(BuildContext context, Product product) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text('Purchased ${product.product_name}'),
//     ),
//   );
// }
