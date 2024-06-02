import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/ProductService.dart';
import 'package:gluttex_impl_business/change_notifier.dart';
import 'package:locator/locator.dart';
import 'package:medicom_catalog/screens/cart_screen.dart';
import 'package:medicom_catalog/screens/components/ProductCard.dart';
import 'package:medicom_catalog/screens/product_form_screen.dart';
import 'package:medicom_catalog/screens/product_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

class CatalogScreen extends StatefulWidget {
  final bool isRightToLeft;

  const CatalogScreen({Key? key, required this.isRightToLeft})
      : super(key: key);

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    // This method can be updated to filter products based on _searchController's text
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProductFormScreen()),
              );
            },
          ),
          const SizedBox(width: GluttexConstants.kDefaultPaddin / 2)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        },
        child: const Icon(Icons.shopping_cart),
      ),
      body: Consumer<ProductNotifier>(
        builder: (context, productNotifier, child) {
          var products = productNotifier.products;
          var filteredProducts = products.where((product) {
            var query = _searchController.text.toLowerCase();
            return product.product_name?.toLowerCase().contains(query) ?? false;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GluttexConstants.kDefaultPaddin),
                  child: RefreshIndicator(
                    onRefresh: productNotifier.fetchProducts,
                    child: _buildProductGrid(filteredProducts),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text(GluttexConstants.noProductsFound));
    }

    return GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: GluttexConstants.kDefaultPaddin,
        crossAxisSpacing: GluttexConstants.kDefaultPaddin,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) => ProductCard(
        product: products[index],
      ),
    );
  }
}
