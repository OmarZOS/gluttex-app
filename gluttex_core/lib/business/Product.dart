import 'dart:typed_data';

class Product {
  final int id_product;
  final int product_provider_id;
  final int product_category_id;
  final int id_product_category;
  final int id_product_image;
  final int product_ref_id;
  final String product_name;
  final String product_brand;
  final String product_barcode;
  final String product_category_desc;
  final Uint8List product_image_data;

  Product(
      {required this.id_product,
      required this.product_provider_id,
      required this.product_category_id,
      required this.id_product_category,
      required this.id_product_image,
      required this.product_ref_id,
      required this.product_name,
      required this.product_brand,
      required this.product_barcode,
      required this.product_category_desc,
      required this.product_image_data});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id_product: json['id_product'] as int,
        product_provider_id: json['product_provider_id'] as int,
        product_category_id: json['product_category_id'] as int,
        id_product_category: json['id_product_category'] as int,
        id_product_image: json['id_product_image'] as int,
        product_ref_id: json['product_ref_id'] as int,
        product_name: json['product_name'] as String,
        product_brand: json['product_brand'] as String,
        product_barcode: json['product_barcode'] as String,
        product_category_desc: json['product_category_desc'] as String,
        product_image_data: json['product_image_data'] as Uint8List);
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product': id_product,
      'product_provider_id': product_provider_id,
      'product_category_id': product_category_id,
      'id_product_category': id_product_category,
      'id_product_image': id_product_image,
      'product_ref_id': product_ref_id,
      'product_name': product_name,
      'product_brand': product_brand,
      'product_barcode': product_barcode,
      'product_category_desc': product_category_desc,
      'product_image_data': product_image_data
    };
  }
}
