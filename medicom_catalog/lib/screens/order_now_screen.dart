import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Cart.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

class OrderNowScreen extends StatefulWidget {
  final Product product;

  const OrderNowScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  _OrderNowScreenState createState() => _OrderNowScreenState();
}

class _OrderNowScreenState extends State<OrderNowScreen> {
  final TextEditingController _quantityController =
      TextEditingController(text: "1");
  double taxRate = 0.19; // Example tax rate
  double discount = 0.0; // Example discount
  int? ordering_user_id;
  double get totalPrice =>
      widget.product.product_price ??
      0.0 + ((widget.product.product_price ?? 0.0) * taxRate) - discount;

  @override
  Future<void> initState() async {
    super.initState();
    ordering_user_id = Provider.of<AppUserNotifier>(context, listen: false)
        .appUser!
        .id_app_user;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(int increment) {
    final currentQuantity = int.tryParse(_quantityController.text) ?? 1;
    final updatedQuantity = (currentQuantity + increment)
        .clamp(1, 100); // Prevent <1 or excessively high values
    _quantityController.text = updatedQuantity.toString();
    setState(() {}); // Trigger UI update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.orderNowTxt),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product details
            Text(
              widget.product.product_name ?? "",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Divider(),
            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.productQuantity,
                    style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateQuantity(-1),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        ),
                        onChanged: (value) {
                          setState(
                              () {}); // Recalculate total price when user edits quantity
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateQuantity(1),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            // Price breakdown
            Text(
                "${AppLocalizations.of(context)!.subtotalTxt} ${(widget.product.product_price ?? 0.0).toStringAsFixed(2)}"),
            Text(
                "${AppLocalizations.of(context)!.taxTxt} ${((widget.product.product_price ?? 0.0) * taxRate).toStringAsFixed(2)}"),
            if (discount > 0)
              Text(
                  "${AppLocalizations.of(context)!.discountText}- ${discount.toStringAsFixed(2)}"),
            const Divider(),
            Text(
              "${AppLocalizations.of(context)!.totalTxt} ${((int.tryParse(_quantityController.text) ?? 1) * (widget.product.product_price ?? 0.0 + ((widget.product.product_price ?? 0.0) * taxRate) - discount)).toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // Order button
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> data = Cart.buildSingleOrderData(
                  product: widget.product,
                  quantity: int.tryParse(_quantityController.text) ?? 1,
                  orderingUserId: ordering_user_id!,
                  discount: discount,
                  taxRate: taxRate,
                );

                String url = GluttexConstants.apiBaseUrl +
                    GluttexConstants.addOrderEndpoint;
                // Place the order
                int? statusCode = await GluttexLocator.get<StorageService>()
                    .insert(url, data);

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
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(AppLocalizations.of(context)!.confirmOrderTxt),
            ),
          ],
        ),
      ),
    );
  }
}
