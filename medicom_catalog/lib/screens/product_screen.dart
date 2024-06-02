import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_impl_business/change_notifier.dart';
import 'package:medicom_catalog/screens/components/add_to_cart.dart';
import 'package:medicom_catalog/screens/components/color_and_size.dart';
import 'package:medicom_catalog/screens/components/counter_with_fav_btn.dart';
import 'package:medicom_catalog/screens/components/description.dart';
import 'package:medicom_catalog/screens/components/dialogue/confirmation_dialogue.dart';
import 'package:medicom_catalog/screens/components/product_title_with_image.dart';
import 'package:medicom_catalog/screens/product_update_form_screen.dart';
import 'package:provider/provider.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.product});

  final Product product;

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () async {
              showConfirmationDialog(
                context,
                'Are you sure you want to delete this product?',
                () async {
                  int? status_code =
                      await Provider.of<ProductNotifier>(context, listen: false)
                          .deleteProduct('${_product.id_product}');

                  Response response = Response();

                  switch (status_code) {
                    case 200:
                      response.color = Colors.green;
                      response.text = GluttexConstants.deleteSuccess;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response.text),
                          backgroundColor: response.color,
                        ),
                      );
                      Navigator.pop(context);
                      break;
                    case 406:
                      response.color = Colors.amberAccent;
                      response.text = GluttexConstants.deleteFailure;
                      break;
                    case 422:
                      response.color = Colors.amberAccent;
                      response.text = GluttexConstants.deleteFailure;
                      break;

                    default:
                      response.color = Colors.red;
                      response.text = GluttexConstants.serverError;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.text),
                      backgroundColor: response.color,
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedProduct = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductEditFormScreen(
                    initialProductName: _product.product_name,
                    initialProductBrand: _product.product_brand,
                    initialProductBarcode: _product.product_barcode,
                    initialProductImage: _product.product_image_data,
                    initialProductTypeId: _product.product_category_id,
                    initialProductPrice: _product.product_price,
                    initialProductQuantity: _product.product_quantity,
                    initialProduct_provider_id: _product.product_provider_id,
                    initialProduct_category_id: _product.product_category_id,
                    initialIdProduct: _product.id_product,
                    initialIdProductImage: _product.id_product_image,
                    initialProductDescription: _product.product_description,
                  ),
                ),
              );

              if (updatedProduct != null) {
                setState(() {
                  _product = updatedProduct;
                });
              }
            },
          ),
          const SizedBox(width: GluttexConstants.kDefaultPaddin / 2)
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
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        ColorAndSize(product: _product),
                        const SizedBox(
                            height: GluttexConstants.kDefaultPaddin / 2),
                        Description(product: _product),
                        const SizedBox(
                            height: GluttexConstants.kDefaultPaddin / 2),
                        const CounterWithFavBtn(),
                        const SizedBox(
                            height: GluttexConstants.kDefaultPaddin / 2),
                        AddToCart(product: _product),
                      ],
                    ),
                  ),
                  ProductTitleWithImage(product: _product),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
