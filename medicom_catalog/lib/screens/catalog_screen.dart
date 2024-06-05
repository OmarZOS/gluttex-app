import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:medicom_catalog/screens/components/ProductCard.dart';
import 'package:medicom_catalog/screens/product_form_screen.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // await Provider.of<ProductNotifier>(context).fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
              hintText: 'Search',
              border: InputBorder.none,
              icon: Icon(Icons.search_outlined)),
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
      body: Consumer<ProductNotifier>(
        builder: (context, productNotifier, child) {
          final products = productNotifier.products;
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
