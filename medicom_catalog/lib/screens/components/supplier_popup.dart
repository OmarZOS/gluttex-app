import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:provider/provider.dart';

class SupplierInfoPopup {
  static void show(BuildContext context, Supplier supplier) {
    // Access your change notifier
    final supplierNotifier =
        Provider.of<SupplierChangeNotifier>(context, listen: false);

    // Fetch similar products when popup opens
    // supplierNotifier.o;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<SupplierChangeNotifier>(
          builder: (context, notifier, _) {
            return AlertDialog(
              title: Row(
                  // children: [
                  //   if (supplier.productProviderDetailsId != null)
                  //     CircleAvatar(
                  //       backgroundImage: NetworkImage(supplier.providerLogoUrl!),
                  //       radius: 20,
                  //     ),
                  //   const SizedBox(width: 12),
                  //   Expanded(child: Text(supplier.providerName)),
                  // ],
                  ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoRow(Icons.phone, supplier.providerContactInfo),
                    if (supplier.locationName != null)
                      _buildInfoRow(Icons.location_on, supplier.locationName!),

                    // Similar products section
                    const SizedBox(height: 16),
                    const Text('Other Products from this Supplier:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // if (notifier.isLoadingSimilarProducts)
                    //   const Center(child: CircularProgressIndicator()),
                    // if (!notifier.isLoadingSimilarProducts &&
                    //     notifier.similarProducts.isEmpty)
                    //   const Text('No other products found'),

                    // if (!notifier.isLoadingSimilarProducts &&
                    //     notifier.similarProducts.isNotEmpty)
                    //   SizedBox(
                    //     height: 120,
                    //     child: ListView.builder(
                    //       scrollDirection: Axis.horizontal,
                    //       itemCount: notifier.productList.length,
                    //       itemBuilder: (context, index) {
                    //         final product = notifier.productList[index];
                    //         return _buildProductCard(context, product);
                    //       },
                    //     ),
                    //   ),

                    const SizedBox(height: 16),
                    _buildLocationButton(context, supplier),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToSupplierDetailsScreen(context, supplier);
                  },
                  child: const Text('Full Details'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  static Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close supplier popup
          // Navigate to product details
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => ProductDetailsScreen(product: product),
          //     ));
        },
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                image: product.product_image_url != null
                    ? DecorationImage(
                        image: NetworkImage(product.product_image_url!),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: product.product_image_url == null
                  ? const Icon(Icons.shopping_bag, size: 30)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              product.product_name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLocationButton(BuildContext context, Supplier supplier) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.map, size: 18),
      label: const Text('View on Map'),
      onPressed: () => _showLocationOnMap(context, supplier),
    );
  }

  static void _navigateToSupplierDetailsScreen(
      BuildContext context, Supplier supplier) {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => SupplierDetailsScreen(supplier: supplier),
    //     )
    //     );
  }

  static void _showLocationOnMap(BuildContext context, Supplier supplier) {
    // Your map implementation here
  }
}
