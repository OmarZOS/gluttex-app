import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Cart.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_impl_business/cart_change_notifier.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartItems = Provider.of<CartChangeNotifier>(context).cart.items;
    final orderingUserId =
        Provider.of<AppUserNotifier>(context).appUser!.id_app_user;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cartText),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> orderedItems =
              Cart.buildOrderData(cartItems, orderingUserId!);

          String url =
              GluttexConstants.apiBaseUrl + GluttexConstants.addOrderEndpoint;

          int? statusCode = await GluttexLocator.get<StorageService>()
              .insert(url, orderedItems);

          Response response = Response();

          switch (statusCode) {
            case 200:
              response.color = Colors.green;
              response.text = AppLocalizations.of(context)!.putSuccess;
              Navigator.pop(context);
              break;
            case 406:
              response.color = Colors.amberAccent;
              response.text =
                  'Error $statusCode: ${AppLocalizations.of(context)!.putFailure}';
              break;
            case 422:
              response.color = Colors.amberAccent;
              response.text =
                  'Error $statusCode: ${AppLocalizations.of(context)!.putFailure}';
              break;

            default:
              response.color = Colors.red;
              response.text =
                  'Error $statusCode: ${AppLocalizations.of(context)!.serverError}';
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
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.emptyCartTxt,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    title: Text(product.product_name ??
                        AppLocalizations.of(context)!.missingText),
                    subtitle: Text(
                      AppLocalizations.of(context)!.orderAmountText(
                          cartItems[index].quantity.toString()),
                    ),
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
