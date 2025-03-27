import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  late int _selectedCategoryId = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCategories();
  }

  void _initializeCategories() {
    final categs =
        AppLocalizations.of(context)!.productCategoryTextList.split(",");
    _categories = [AppLocalizations.of(context)!.allText, ...categs];

    Provider.of<ProductNotifier>(context, listen: false).productCategories =
        categs;
  }

  void _filterProducts() {
    setState(() {});
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryId = index;
    });
    Provider.of<ProductNotifier>(context, listen: false)
        .fetchProducts(_selectedCategoryId);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !Provider.of<ProductNotifier>(context, listen: false).isLoading) {
      Provider.of<ProductNotifier>(context, listen: false)
          .fetchProducts(_selectedCategoryId);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        overlayOpacity: 0.5,
        spacing: 10,
        children: [
          SpeedDialChild(
            child: Icon(Icons.shopping_basket,
                color: Theme.of(context).colorScheme.onSecondary),
            label: AppLocalizations.of(context)?.ordersText,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersScreen()),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.shopping_cart,
                color: Theme.of(context).colorScheme.onSecondary),
            label: AppLocalizations.of(context)?.cartText,
            backgroundColor: Theme.of(context).colorScheme.secondary,
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
            icon: Icon(Icons.search_outlined,
                color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon:
                Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
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
          final products =
              productNotifier.filterProductsByCategory(_selectedCategoryId);
          var filteredProducts = products.where((product) {
            var query = _searchController.text.toLowerCase();
            return (product.product_name?.toLowerCase().contains(query) ??
                false);
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
                      await productNotifier.fetchProducts(_selectedCategoryId,
                          reset: true);
                    },
                    child: _buildProductGrid(filteredProducts, productNotifier),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          int index = _categories.indexOf(category);
          bool isSelected = _selectedCategoryId == index;
          String? iconPath = 'assets/icons/$index.svg';

          return GestureDetector(
            onTap: () => _selectCategory(_categories.indexOf(category)),
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: GluttexConstants.kDefaultPaddin / 2,
                vertical: GluttexConstants.kDefaultPaddin / 4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: GluttexConstants.kDefaultPaddin / 2,
                vertical: GluttexConstants.kDefaultPaddin / 3,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SVG Icon
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      iconPath,
                      package: "medicom_catalog",
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Category Text
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(
      List<Product> products, ProductNotifier productNotifier) {
    if (products.isEmpty && !productNotifier.isLoading) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.noProductsFound ?? "",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
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
        // Loading Indicator
        if (productNotifier.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
