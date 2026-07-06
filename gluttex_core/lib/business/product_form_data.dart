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
  double? price;
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

  // Convert to Product object
  Product toProduct() {
    return Product(
      id_product: productId ?? 0,
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
      product_quantity: quantity ?? 0,
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
    quantity = product.product_quantity;
    quantifier = product.product_quantifier ?? 'pc';
    ownerId = product.product_owner_id;
    productDescription = product.product_description;
    providerId = product.product_provider_id;
    categoryId = product.product_category_id;
    productId = product.id_product;
    imageId = product.id_product_image;
    isUpdate = true;
  }
}
