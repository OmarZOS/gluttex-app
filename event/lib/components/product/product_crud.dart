import 'dart:developer';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'product_cache.dart';
import 'product_state.dart';

class ProductCrud {
  final ProductService _service;
  final ProductCache _cache;
  final ProductState _state;

  ProductCrud({
    required ProductService service,
    required ProductCache cache,
    required ProductState state,
  })  : _service = service,
        _cache = cache,
        _state = state;

  Future<Product?> createOrUpdate(Product product) async {
    if (product.productImage != null) {
      final url = await product.productImage?.uploadImage();
      product.product_image_url = url;
    }

    final result = product.id_product == 0
        ? await _service.addProduct(product)
        : await _service.updateProduct(product);

    if (result != null && result.id_product != null) {
      _cache.invalidateProduct(result.id_product);
      _cache.cacheProduct(result);
      _updateInList(result);
    }

    return result;
  }

  Future<int?> delete(String idProduct) async {
    try {
      final status = await _service.deleteProduct(idProduct);
      if (status != null) {
        final id = int.parse(idProduct);
        _cache.invalidateProduct(id);
        _state.products.removeWhere((p) => p.id_product == id);
      }
      return status;
    } catch (e) {
      log("Failed to delete product: $e");
      return null;
    }
  }

  void _updateInList(Product product) {
    final index =
        _state.products.indexWhere((p) => p.id_product == product.id_product);
    if (index != -1) {
      _state.products[index] = product;
    }
  }
}
