import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:gluttex_impl_business/cart_change_notifier.dart';
import 'package:medicom_catalog/screens/cart_screen.dart';
import 'package:medicom_catalog/screens/components/ProductOwner.dart';
import 'package:medicom_catalog/screens/components/add_to_cart.dart';
import 'package:medicom_catalog/screens/components/quantity_and_ref.dart';
import 'package:medicom_catalog/screens/components/counter_with_fav_btn.dart';
import 'package:medicom_catalog/screens/components/description.dart';
import 'package:medicom_catalog/screens/components/dialogue/confirmation_dialogue.dart';
import 'package:medicom_catalog/screens/components/product_title_with_image.dart';
import 'package:medicom_catalog/screens/product_update_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:sse_client/sse_client.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.product});

  final Product product;

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Product _product;
  final PanelController _panelController = PanelController();
  // late EventSource _eventSource;
  late ProductNotifier _productNotifier;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _subscribeToProductUpdates(); // Subscribe to SSE on screen open
  }

  @override
  void dispose() async {
    _productNotifier.stopPollingProductUpdates();
    // _unsubscribeFromProductUpdates(); // Unsubscribe on screen exit
    super.dispose();
  }

  void _subscribeToProductUpdates() async {
    _productNotifier = Provider.of<ProductNotifier>(context, listen: false);
    _productNotifier.startPollingProductUpdates(_product);
  }

  void _unsubscribeFromProductUpdates() {}

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to CartScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart),
              Positioned(
                right: -4,
                top: -4,
                child: Consumer<CartChangeNotifier>(
                  builder: (context, cart, child) {
                    return cart.cartItemCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cart.cartItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            is_product_owner(context, _product.product_owner_id ?? 0)
                ? (IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      showConfirmationDialog(
                        context,
                        AppLocalizations.of(context)!
                            .productdeletionConfirmationMessage,
                        () async {
                          int? statusCode = await Provider.of<ProductNotifier>(
                                  context,
                                  listen: false)
                              .deleteProduct('${_product.id_product}');

                          Response response = Response();

                          switch (statusCode) {
                            case 200:
                              response.color = Colors.green;
                              response.text =
                                  AppLocalizations.of(context)!.deleteSuccess;
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
                              response.text =
                                  AppLocalizations.of(context)!.deleteFailure;
                              break;
                            case 422:
                              response.color = Colors.amberAccent;
                              response.text =
                                  AppLocalizations.of(context)!.deleteFailure;
                              break;

                            default:
                              response.color = Colors.red;
                              response.text =
                                  AppLocalizations.of(context)!.serverError;
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
                  ))
                : Container(),
            is_product_owner(context, _product.product_owner_id ?? 0)
                ? (IconButton(
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
                            initialProductOwner: _product.product_owner_id,
                            initialProductTypeId: _product.product_category_id,
                            initialProductPrice: _product.product_price,
                            initialProductQuantity: _product.product_quantity,
                            initialProduct_provider_id:
                                _product.product_provider_id,
                            initialProduct_category_id:
                                _product.product_category_id,
                            initialIdProduct: _product.id_product,
                            initialIdProductImage: _product.id_product_image,
                            initialProductDescription:
                                _product.product_description,
                          ),
                        ),
                      );

                      if (updatedProduct != null) {
                        setState(() {
                          _product = updatedProduct;
                        });
                      }
                    },
                  ))
                : Container(),
            const SizedBox(width: GluttexConstants.kDefaultPaddin / 2)
          ],
        ),
        body: SlidingUpPanel(
          controller: _panelController,
          minHeight: 0,
          maxHeight: 300,
          color: Colors.grey,
          // backdropOpacity: 0.5,
          panel: _buildSlidingPanel(),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: size.height,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        // color: Colors.grey,
                        margin: EdgeInsets.only(top: size.height * 0.3),
                        padding: EdgeInsets.only(
                          top: size.height * 0.12,
                          left: GluttexConstants.kDefaultPaddin,
                          right: GluttexConstants.kDefaultPaddin,
                        ),
                        decoration: const BoxDecoration(
                          // color: Colors.grey,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Consumer<ProductNotifier>(
                              builder: (context, productNotifier, child) {
                                return QuantityAndRef(
                                    product: productNotifier.products
                                        .firstWhere((element) =>
                                            element.id_product ==
                                            _product.id_product));
                              },
                            ),
                            const SizedBox(
                                height: GluttexConstants.kDefaultPaddin / 2),
                            Description(product: _product),
                            const SizedBox(
                                height: GluttexConstants.kDefaultPaddin / 2),
                            // const CounterWithFavBtn(),
                            const SizedBox(
                                height: GluttexConstants.kDefaultPaddin / 2),
                            AddToCart(
                              product: widget.product,
                              onAddToCartPressed: () {
                                _panelController
                                    .open(); // Open the sliding panel
                              },
                            ),
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
        ));
  }

  Widget _buildSlidingPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              // color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  // color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image,
                    size: 40), // Replace with product image
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.product_name ??
                        AppLocalizations.of(context)!.missingText,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    AppLocalizations.of(context)!.price(
                        (widget.product.product_price ?? 0 * quantity)
                            .toStringAsFixed(2)),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (quantity > 1) quantity--;
                  });
                },
                icon: const Icon(Icons.remove_circle,
                    size: 32, color: Colors.red),
              ),
              Text(
                "$quantity",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
                icon:
                    const Icon(Icons.add_circle, size: 32, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Provider.of<CartChangeNotifier>(context, listen: false)
                  .addItem(widget.product, quantity);
              _panelController.close();
            },
            child:
                Text(AppLocalizations.of(context)!.cartAddConfirmationMessage),
          ),
        ],
      ),
    );
  }
}
