import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:medicom_catalog/screens/cart_screen.dart';
import 'package:medicom_catalog/screens/components/ProductCard.dart';
import 'package:medicom_catalog/screens/orders_screen.dart';
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
  // late String _selectedCategory = AppLocalizations.of(context)!.allText;
  late int _selectedCategoryId = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showMoreButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    setState(() {});
  }

  void _selectCategory(int index, String category) {
    setState(() {
      _selectedCategoryId = index;
      // _selectedCategory = category;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Check if user reached the end of scrolling
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent -
            GluttexConstants.kDefaultPaddin) {
      if (!_showMoreButton) {
        setState(() {
          _showMoreButton = true;
        });
      }
    } else {
      if (_showMoreButton) {
        setState(() {
          _showMoreButton = false;
        });
      }
    }
  }

  void _loadMoreProducts() {
    Provider.of<ProductNotifier>(context, listen: false)
        .fetchProducts(_selectedCategoryId);
    _showMoreButton = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        foregroundColor: Theme.of(context).primaryColor,
        overlayOpacity: 0.5,
        spacing: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.shopping_basket),
            label: AppLocalizations.of(context)?.ordersText,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersScreen()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.shopping_cart),
            label: AppLocalizations.of(context)?.cartText,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
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
      body: Stack(
        children: [
          Consumer<ProductNotifier>(
            builder: (context, productNotifier, child) {
              final products = productNotifier.products;
              var filteredProducts = products.where((product) {
                var query = _searchController.text.toLowerCase();
                var matchesCategory = (_selectedCategoryId == 0) ||
                    ((product.product_category_id ?? 1)) == _selectedCategoryId;
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
                        onRefresh: () async {
                          await productNotifier
                              .fetchProducts(_selectedCategoryId, reset: true);
                        },
                        child: _buildProductGrid(filteredProducts),
                      ),
                    ),
                  ),
                  // Show More Button (ONLY When Reached Bottom)
                  if (_showMoreButton)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedOpacity(
                            opacity: 0.9,
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton.icon(
                              onPressed: _loadMoreProducts,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).hintColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              icon: Icon(Icons.expand_more,
                                  color: Theme.of(context).indicatorColor),
                              label: Text(
                                AppLocalizations.of(context)?.showMoreText ??
                                    "Show More",
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Consumer<ProductNotifier>(
        builder: (context, productNotifier, child) {
      if (_categories.isEmpty) {
        _categories.add(AppLocalizations.of(context)!.allText);
        _categories.addAll(
            AppLocalizations.of(context)!.productCategoryTextList.split(","));
        _selectedCategoryId = 0;
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            bool isSelected =
                _selectedCategoryId == _categories.indexOf(category);
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
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    // color: isSelected ? Colors.white : Colors.black,
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
        child: Text(AppLocalizations.of(context)?.noProductsFound ?? ""),
      );
    }

    return Column(
      children: [
        // Product Grid
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}
