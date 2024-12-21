import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
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
  late List<String> _categories = [];
  late String _selectedCategory = AppLocalizations.of(context)!.allText;
  late int _selectedCategoryId = 0;
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    setState(() {});
  }

  void _selectCategory(int index, String category) {
    setState(() {
      _selectedCategoryId = index;
      _selectedCategory = category;
    });
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
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.searchTxt,
            border: InputBorder.none,
            icon: const Icon(Icons.search_outlined),
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
          const SizedBox(width: GluttexConstants.kDefaultPaddin / 2),
        ],
      ),
      body: Consumer<ProductNotifier>(
        builder: (context, productNotifier, child) {
          final products = productNotifier.products;
          var filteredProducts = products.where((product) {
            var query = _searchController.text.toLowerCase();
            var matchesCategory = _selectedCategory ==
                    AppLocalizations.of(context)?.allText ||
                ((product.product_category_id ?? 1) - 1) == _selectedCategoryId;
            return (product.product_name?.toLowerCase().contains(query) ??
                    false) &&
                matchesCategory;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildCategoryRow(),
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

  Widget _buildCategoryRow() {
    return Consumer<ProductNotifier>(
        builder: (context, productNotifier, child) {
      if (_categories.isEmpty) {
        _categories.addAll(
            AppLocalizations.of(context)!.productCategoryTextList.split(","));
        _categories.add(AppLocalizations.of(context)!.allText);
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            bool isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () =>
                  _selectCategory(_categories.indexOf(category), category),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: GluttexConstants.kDefaultPaddin / 2,
                  vertical: GluttexConstants.kDefaultPaddin / 4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: GluttexConstants.kDefaultPaddin,
                  vertical: GluttexConstants.kDefaultPaddin / 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)?.noProductsFound ?? ""));
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
