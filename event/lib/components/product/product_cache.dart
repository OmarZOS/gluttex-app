import 'package:gluttex_core/business/Product.dart';

class ProductCache {
  final Map<int, Product> _productCache = {};
  final Map<String, List<int>> _listCache = {};
  final Map<int, DateTime> _supplierCacheTime = {};
  final Map<int, List<Product>> _supplierProductsCache = {};

  bool _enabled = true;
  static const _supplierCacheDuration = Duration(minutes: 5);

  bool get isEnabled => _enabled;
  int get productCacheSize => _productCache.length;
  int get listCacheSize => _listCache.length;

  void enable(bool enable) {
    _enabled = enable;
    if (!enable) clearAll();
  }

  void clearAll() {
    _productCache.clear();
    _listCache.clear();
    _supplierProductsCache.clear();
    _supplierCacheTime.clear();
  }

  // Product cache
  void cacheProduct(Product product) {
    if (!_enabled || product.id_product == null) return;
    _productCache[product.id_product!] = product;
  }

  Product? getProduct(int id) {
    if (!_enabled) return null;
    return _productCache[id];
  }

  void invalidateProduct(int? id) {
    if (id != null) {
      _productCache.remove(id);
    } else {
      _productCache.clear();
      _listCache.clear();
    }
  }

  // List cache
  void cacheList(String key, List<Product> products) {
    if (!_enabled) return;
    _listCache[key] = products.map((p) => p.id_product!).toList();
    for (final p in products) {
      cacheProduct(p);
    }
  }

  List<Product>? getList(String key) {
    if (!_enabled) return null;
    final ids = _listCache[key];
    if (ids == null) return null;

    final products = <Product>[];
    for (final id in ids) {
      final cached = getProduct(id);
      if (cached == null) return null;
      products.add(cached);
    }
    return products;
  }

  void clearListCache() => _listCache.clear();

  // Supplier products cache
  void cacheSupplierProducts(int supplierId, List<Product> products) {
    if (!_enabled) return;
    _supplierProductsCache[supplierId] = products;
    _supplierCacheTime[supplierId] = DateTime.now();
    for (final p in products) {
      cacheProduct(p);
    }
  }

  List<Product>? getSupplierProducts(int supplierId) {
    if (!_enabled) return null;
    final cached = _supplierProductsCache[supplierId];
    final time = _supplierCacheTime[supplierId];
    if (cached != null && time != null) {
      if (DateTime.now().difference(time) < _supplierCacheDuration) {
        return cached;
      }
    }
    return null;
  }

  void invalidateSupplierCache(int supplierId) {
    _supplierProductsCache.remove(supplierId);
    _supplierCacheTime.remove(supplierId);
  }

  bool hasValidSupplierCache(int supplierId) {
    final time = _supplierCacheTime[supplierId];
    if (time == null) return false;
    return DateTime.now().difference(time) < _supplierCacheDuration;
  }
}
