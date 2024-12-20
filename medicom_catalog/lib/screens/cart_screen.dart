import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Cart.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_impl_business/cart_change_notifier.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartItems = Provider.of<CartChangeNotifier>(context).cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<dynamic> orderedItems = [];
          for (CartItem item in cartItems) {
            orderedItems.add({
              "id_ordered_item": 0,
              "ordered_product_id": item.product.id_product ?? 0,
              "order_ref": 0,
              "product_discount": 0,
              "ordered_quantity": item.quantity,
              "unit_price": item.product.product_price ?? 0.0,
              "applied_vat": 0.0
            });
          }
          Map<String, dynamic> data = {
            "ordered_items": orderedItems,
            "submitted_order": {"ordering_user_id": 1}
          };

          String url =
              GluttexConstants.apiBaseUrl + GluttexConstants.addOrderEndpoint;

          int? statusCode =
              await GluttexLocator.get<StorageService>().insert(url, data);

          Response response = Response();

          switch (statusCode) {
            case 200:
              response.color = Colors.green;
              response.text = GluttexConstants.putSuccess;
              Navigator.pop(context);
              break;
            case 406:
              response.color = Colors.amberAccent;
              response.text =
                  'Error $statusCode: ${GluttexConstants.putFailure}';
              break;
            case 422:
              response.color = Colors.amberAccent;
              response.text =
                  'Error $statusCode: ${GluttexConstants.putFailure}';
              break;

            default:
              response.color = Colors.red;
              response.text =
                  'Error $statusCode: ${GluttexConstants.serverError}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.text),
              backgroundColor: response.color,
            ),
          );
        },
        child: const Icon(
          Icons.done_outline_rounded,
          color: Colors.green,
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                GluttexConstants.emptyCartTxt,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final product = cartItems[index].product;
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.food_bank_sharp),
                    title: Text(
                        product.product_name ?? GluttexConstants.missingText),
                    subtitle: Text('${GluttexConstants.productQuantity} ${cartItems[index].quantity}'),
                    trailing: IconButton(
                      onPressed: () {
                        Provider.of<CartChangeNotifier>(context, listen: false)
                            .removeItem(product);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
