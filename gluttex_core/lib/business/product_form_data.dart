import 'dart:io';

import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/business/Product.dart';

class ProductFormData {
  // Form fields
  String? productName;
  String? productBrand;
  String? productBarcode;
  String? productDescription;
  GluttexImage? image;
  File? imageFile;
  int? typeId;

  /// Customer-facing price (what the buyer pays). Stored as `product_price`.
  double? price;

  /// Supplier-side cost (what the supplier paid or produces it for).
  /// Stored as `product_base_price`. Optional — a product can be listed
  /// without a known cost, in which case margin is undefined.
  double? productBasePrice;

  int? quantity;
  String? quantifier;
  int? ownerId;
  int? providerId;
  int? categoryId;
  int? productId;
  int? imageId;
  String? imageUrl;
  bool isUpdate = false;
  int selectedProviderId = 0;

  bool lockProvider = false;

  /// "VISIBLE" | "HIDDEN". Defaults to VISIBLE for new products.
  /// Preserved on update so the toggle in the editor view round-trips.
  String visibility = 'VISIBLE';

  /// Quantity already reserved by carts and pending orders. Read-only
  /// from the form's perspective, but carried through so the Product
  /// built by [toProduct] keeps the current value on update.
  int? reservedQuantity;

  /// Origin (country / region) reference. Carried through untouched.
  int? originId;

  // Convert to Product object
  Product toProduct() {
    return Product(
      id_product: productId ?? 0,
      // Always use the (possibly locked) selected provider.
      product_provider_id: selectedProviderId,
      product_quantifier: quantifier ?? 'pc',
      product_owner_id: ownerId ?? 1,
      id_product_category: typeId ?? categoryId ?? 1,
      product_category_id: typeId ?? categoryId ?? 1,
      id_product_image: imageId,
      product_ref_id: productId,
      product_name: productName ?? '',
      product_brand: productBrand ?? '',
      product_barcode: productBarcode ?? '',
      product_image_url: imageUrl,
      product_category_name: '',
      product_price: price ?? 0.0,
      product_base_price: productBasePrice ?? 0.0,
      product_quantity: quantity ?? 0,
      product_reserved_quantity: reservedQuantity ?? 0,
      product_visibility: visibility,
      product_origin_id: originId,
      product_description: productDescription ?? '',
      product_created_at: null,
      product_last_updated: null,
    );
  }

  // Populate from existing product
  void populateFromProduct(Product product) {
    productName = product.product_name;
    productBrand = product.product_brand;
    productBarcode = product.product_barcode;
    imageUrl = product.product_image_url;
    typeId = product.product_category_id ?? 1;
    price = product.product_price;
    productBasePrice = product.product_base_price;
    quantity = product.product_quantity;
    quantifier = product.product_quantifier ?? 'pc';
    ownerId = product.product_owner_id;
    productDescription = product.product_description;
    providerId = product.product_provider_id;
    categoryId = product.product_category_id;
    productId = product.id_product;
    imageId = product.id_product_image;
    isUpdate = true;
    selectedProviderId = product.product_provider_id ?? 0;
    lockProvider = true;

    // Fields carried through on update
    visibility = product.product_visibility ?? 'VISIBLE';
    reservedQuantity = product.product_reserved_quantity;
    originId = product.product_origin_id;
  }
}
