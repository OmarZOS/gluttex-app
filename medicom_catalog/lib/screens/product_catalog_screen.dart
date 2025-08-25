import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/preferenceChangeNotifier.dart';
import 'package:medicom_catalog/screens/components/ProductCard.dart';
import 'package:provider/provider.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({Key? key}) : super(key: key);

  @override
  _ProductCatalogScreenState createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _categories = [];
  int _selectedCategoryId = 0;
  final ScrollController _scrollController = ScrollController();
  late ProductNotifier provider;
  @override
  void initState() {
    provider = Provider.of<ProductNotifier>(context, listen: false);
    super.initState();
    _searchController.addListener(_filterProducts);
    _scrollController.addListener(_scrollListener);
    provider.fetchProducts();
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

  void _filterProducts() {}

  void _selectCategory(int index) {
    _selectedCategoryId = index;
    Provider.of<ProductNotifier>(context, listen: false)
        .fetchProducts(categoryId: _selectedCategoryId);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !Provider.of<ProductNotifier>(context, listen: false).isLoading) {
      Provider.of<ProductNotifier>(context, listen: false)
          .fetchProducts(categoryId: provider.currentCategory);
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
    final isRTL = context.read<LocaleProvider>().locale?.languageCode == "ar";
    return Scaffold(
      floatingActionButton: (Provider.of<AppUserNotifier>(context,
                  listen: false)
              .isLoggedIn)
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              overlayOpacity: 0.5,
              spacing: 10,
              direction:
                  isRTL ? SpeedDialDirection.right : SpeedDialDirection.left,
              switchLabelPosition:
                  true, // ✅ Forces labels to appear on the other side (RTL aware)
              isOpenOnStart: false,
              spaceBetweenChildren: 8,
              childMargin: EdgeInsets.symmetric(
                horizontal:
                    Localizations.localeOf(context).toString() == 'ar' ? 16 : 8,
              ),

              children: [
                SpeedDialChild(
                  child: Icon(Icons.shopping_basket,
                      color: Theme.of(context).colorScheme.onPrimary),
                  label: AppLocalizations.of(context)?.ordersText,
                  labelBackgroundColor: Theme.of(context).colorScheme.primary,
                  labelStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.ordersPage,
                    );
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.shopping_cart,
                      color: Theme.of(context).colorScheme.onPrimary),
                  label: AppLocalizations.of(context)?.cartText,
                  labelBackgroundColor: Theme.of(context).colorScheme.primary,
                  labelStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.cartPage,
                    );
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.add_box_outlined,
                      color: Theme.of(context).colorScheme.onPrimary),
                  label: AppLocalizations.of(context)?.addProductTxt,
                  labelBackgroundColor: Theme.of(context).colorScheme.primary,
                  labelStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.productCreate);
                  },
                ),
              ],
            )
          : null,
      appBar: AppBar(
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.searchTxt,
              prefixIcon: Icon(Icons.search_outlined,
                  color: Theme.of(context).colorScheme.onSurface),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
      body: Consumer<ProductNotifier>(
        builder: (context, productNotifier, child) {
          final products = productNotifier
              .filterProductsByCategory(provider.currentCategory);
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
                      horizontal: GluttexConstants.kDefaultPaddin / 4),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await productNotifier.fetchProducts(
                          categoryId: provider.currentCategory, reset: true);
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
          bool isSelected = provider.currentCategory == index;
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
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
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
        if (productNotifier.isLoading && products.isNotEmpty)
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
