import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:medicom_catalog/screens/order_now_screen.dart';

class AddToCart extends StatelessWidget {
  const AddToCart({
    super.key,
    required this.product,
    required this.onAddToCartPressed,
  });

  final Product product;
  final VoidCallback onAddToCartPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: GluttexConstants.kDefaultPaddin),
      child: Row(
        children: <Widget>[
          Container(
            margin:
                const EdgeInsets.only(right: GluttexConstants.kDefaultPaddin),
            height: 50,
            width: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(),
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                "assets/icons/add_to_cart.svg",
                package: "medicom_catalog",
              ),
              onPressed: onAddToCartPressed, // Trigger the sliding panel
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final selectedStore = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderNowScreen(
                      product: product,
                    ),
                  ),
                );
                if (selectedStore != null) {
                  // print("Selected Store: $selectedStore");
                  // Handle the selected store (e.g., proceed to checkout)
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.orderNowTxt.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
