import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

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

  double get totalPrice =>
      widget.product.product_price ??
      0.0 + ((widget.product.product_price ?? 0.0) * taxRate) - discount;

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
        title: const Text(GluttexConstants.orderNowTxt),
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
                const Text(GluttexConstants.productQuantity,
                    style: TextStyle(fontSize: 16)),
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
                "${GluttexConstants.subtotalTxt}\$${(widget.product.product_price ?? 0.0).toStringAsFixed(2)}"),
            Text(
                "${GluttexConstants.taxTxt}\$${((widget.product.product_price ?? 0.0) * taxRate).toStringAsFixed(2)}"),
            if (discount > 0)
              Text(
                  "${GluttexConstants.discountText}-\$${discount.toStringAsFixed(2)}"),
            const Divider(),
            Text(
              "${GluttexConstants.totalTxt}\$${((int.tryParse(_quantityController.text) ?? 1) * (widget.product.product_price ?? 0.0 + ((widget.product.product_price ?? 0.0) * taxRate) - discount)).toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // Order button
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> data = {
                  "ordered_items": [
                    {
                      "id_ordered_item": 0,
                      "ordered_product_id": widget.product.id_product ?? 0,
                      "order_ref": 0,
                      "product_discount": discount,
                      "ordered_quantity":
                          int.tryParse(_quantityController.text) ?? 1,
                      "unit_price": widget.product.product_price ?? 0.0,
                      "applied_vat": taxRate
                    }
                  ],
                  "submitted_order": {
                    "id_placed_order": 0,
                    "ordered_timestamp": "string",
                    "order_discount": 0,
                    "ordering_user_id": 1
                  }
                };

                String url = GluttexConstants.apiBaseUrl +
                    GluttexConstants.addOrderEndpoint;
                // Place the order
                int? statusCode = await GluttexLocator.get<StorageService>()
                    .insert(url, data);

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
                        'Error $statusCode: ' + GluttexConstants.putFailure;
                    break;
                  case 422:
                    response.color = Colors.amberAccent;
                    response.text =
                        'Error $statusCode: ' + GluttexConstants.putFailure;
                    break;

                  default:
                    response.color = Colors.red;
                    response.text =
                        'Error $statusCode: ' + GluttexConstants.serverError;
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
              child: const Text(GluttexConstants.confirmOrderTxt),
            ),
          ],
        ),
      ),
    );
  }
}
