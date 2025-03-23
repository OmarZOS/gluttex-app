import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_impl_business/cart_change_notifier.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int userId = Provider.of<AppUserNotifier>(context, listen: false)
        .appUser!
        .id_app_user!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.ordersText),
      ),
      body: FutureBuilder(
        future: Provider.of<CartChangeNotifier>(context, listen: false)
            .fetchOrders(appUserId: userId),
        builder: (context, snapshot) {
          return Consumer<CartChangeNotifier>(
            builder: (context, cartNotifier, child) {
              if (cartNotifier.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = cartNotifier.orders;

              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.noOrdersTxt,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const Icon(Icons.shopping_bag_outlined),
                      title: Text(AppLocalizations.of(context)!
                          .orderIdentifierTxt(order.id_order.toString())),
                      subtitle: Text(
                        AppLocalizations.of(context)!
                            .price(order.total_price.toString()),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          // Implement order deletion if needed
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
