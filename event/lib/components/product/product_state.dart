import 'package:gluttex_core/business/Product.dart';

class ProductState {
  final List<Product> products = [];
  final Map<int, int> cartQuantities = {};
  final List<Product> cartItems = [];
  List<String> categories = [];

  bool isLoading = false;
  bool isCartLoading = false;
  bool hasMoreProducts = true;
  int currentPage = 0;
  int currentCategory = 0;
  int currentUserId = 0;
  int currentProviderId = 0;
  String currentSearchQuery = "";
  int itemsPerPage = 20;

  void reset() {
    products.clear();
    cartQuantities.clear();
    cartItems.clear();
    isLoading = false;
    isCartLoading = false;
    hasMoreProducts = true;
    currentPage = 0;
    currentCategory = 0;
    currentUserId = 0;
    currentProviderId = 0;
    currentSearchQuery = "";
  }

  void resetPagination() {
    currentPage = 0;
    hasMoreProducts = true;
    products.clear();
  }

  bool get supportsSupplierFilter => true;

  List<Product> filterByCategory(int categoryId) {
    if (categoryId == 0) return List.unmodifiable(products);
    return products
        .where((product) => product.product_category_id == categoryId)
        .toList();
  }

  List<Product> filterBySupplier(int supplierId) {
    return products
        .where((product) => product.product_provider_id == supplierId)
        .toList();
  }
}
