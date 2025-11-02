import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:gluttex_core/app/GluttexImage.dart';

class Product {
  final int? id_product;
  final int? product_provider_id;
  final int? product_category_id;
  final int? id_product_category;
  final int? id_product_image;
  final int? product_ref_id;
  final int? product_owner_id;
  final String? product_name;
  final String? product_brand;
  final String? product_barcode;
  final double? product_price;
  final String? product_quantifier;
  final int? product_quantity;
  final String? product_category_desc;
  String? product_image_url;
  final String? product_description;
  final DateTime? product_created_at;
  final DateTime? product_last_updated;

  GluttexImage? productImage;

  Product(
      {required this.id_product,
      required this.product_provider_id,
      required this.product_category_id,
      required this.id_product_category,
      required this.id_product_image,
      required this.product_ref_id,
      required this.product_name,
      required this.product_brand,
      required this.product_quantifier,
      required this.product_barcode,
      required this.product_category_desc,
      // required this.product_image_data,
      required this.product_image_url,
      required this.product_price,
      required this.product_quantity,
      required this.product_description,
      required this.product_created_at,
      required this.product_last_updated,
      required this.product_owner_id});

  factory Product.fromJson(dynamic json) {
    String? imageUrl;
    int imageId = 0;
    String productCategory = "Missing";
    // log("Got product");

    log("$json");
    if (json['product_image'] != null && json['product_image'] is List) {
      if (json['product_image']?.isNotEmpty) {
        imageId = json['product_image'].last["id_product_image"] ?? 0;
        imageUrl = json['product_image'].last["product_image_url"];
      }
    }

    if (json['product_category'] != null) {
      productCategory = json['product_category']['product_category_desc'];
    }

    return Product(
      id_product: json['id_product'] ?? 0,
      product_provider_id: json['product_provider_id'] ?? 0,
      product_category_id: json['product_category_id'] ?? 0,
      id_product_category: json['product_category_id'] ?? 0,
      id_product_image: imageId,
      product_ref_id: json['product_ref_id'] ?? 0,
      product_name: json['product_name'] ?? "",
      product_brand: json['product_brand'] ?? "",
      product_barcode: json['product_barcode'] ?? "",
      product_quantifier: json['product_quantifier'] ?? "",
      product_category_desc: productCategory,
      // product_image_data: null,
      product_image_url: imageUrl ?? "",
      product_price: json['product_price'] ?? 0.0,
      product_quantity: json['product_quantity'] ?? 0,
      product_description: json['product_description'],
      product_created_at: DateTime.now(),
      product_last_updated: DateTime.now(),
      product_owner_id: json['product_owner'],
      // product_created_at: DateTime.tryParse(json['created'] ?? 0),
      // product_last_updated: DateTime.tryParse(json['last_updated'] ?? 0),
    );
  }

  factory Product.fromSearchJson(dynamic json) {
    if (json == null) {
      return Product(
        id_product: 0,
        product_provider_id: 0,
        product_category_id: 0,
        id_product_category: 0,
        id_product_image: 0,
        product_ref_id: 0,
        product_name: "",
        product_brand: "",
        product_barcode: "",
        product_quantifier: "",
        product_category_desc: "Missing",
        product_image_url: "",
        product_price: 0.0,
        product_quantity: 0,
        product_description: "",
        product_created_at: DateTime.now(),
        product_last_updated: DateTime.now(),
        product_owner_id: 0,
      );
    }

    // handle images if they exist
    String? imageUrl;
    int imageId = 0;
    if (json['product_image'] != null && json['product_image'] is List) {
      final images = json['product_image'] as List;
      if (images.isNotEmpty) {
        final lastImage = images.last as Map<String, dynamic>;
        imageId = lastImage["id_product_image"] ?? 0;
        imageUrl = lastImage["product_image_url"];
      }
    }

    // handle category description if present
    String productCategory = "Missing";
    if (json['product_category'] != null &&
        json['product_category'] is Map<String, dynamic>) {
      productCategory =
          json['product_category']?['product_category_desc'] ?? "Missing";
    }

    return Product(
      id_product: json['id_product'] ?? 0,
      product_provider_id: json['product_provider_id'] ?? 0,
      product_category_id: json['product_category_id'] ?? 0,
      id_product_category: json['product_category_id'] ?? 0,
      id_product_image: imageId,
      product_quantifier: json['product_quantifier'] ?? "",
      product_ref_id: json['product_ref_id'] ?? 0,
      product_name: json['product_name'] ?? "",
      product_brand: json['product_brand'] ?? "",
      product_barcode: json['product_barcode'] ?? "",
      product_category_desc: productCategory,
      product_image_url: imageUrl ?? "",
      product_price: (json['product_price'] is num)
          ? (json['product_price'] as num).toDouble()
          : 0.0,
      product_quantity: json['product_quantity'] ?? 0,
      product_description: json['product_description'] ?? "",
      product_created_at:
          DateTime.tryParse(json['created'] ?? "") ?? DateTime.now(),
      product_last_updated:
          DateTime.tryParse(json['last_updated'] ?? "") ?? DateTime.now(),
      product_owner_id: json['product_owner'] ?? 0,
    );
  }

  Product copyWith({
    int? id_product,
    int? product_quantity,
  }) {
    return Product(
        id_product: id_product ?? this.id_product,
        product_provider_id: product_provider_id ?? product_provider_id,
        product_category_id: product_category_id ?? product_category_id,
        id_product_category: id_product_category ?? id_product_category,
        id_product_image: id_product_image ?? id_product_image,
        product_ref_id: product_ref_id ?? product_ref_id,
        product_name: product_name ?? product_name,
        product_brand: product_brand ?? product_brand,
        product_barcode: product_barcode ?? product_barcode,
        product_quantifier: product_quantifier ?? product_quantifier,
        product_category_desc: product_category_desc ?? product_category_desc,
        product_image_url: product_image_url ?? product_image_url,
        product_price: product_price ?? product_price,
        product_quantity: product_quantity ?? this.product_quantity,
        product_description: product_description ?? product_description,
        product_created_at: product_created_at ?? product_created_at,
        product_last_updated: product_last_updated ?? product_last_updated,
        product_owner_id: product_owner_id ?? product_owner_id);
  }

  Map<String, dynamic> toJson() {
    return {
      "product": {
        'id_product': id_product ?? 0,
        'product_provider_id': product_provider_id ?? "",
        'product_category_id': product_category_id ?? "",
        'id_product_category': id_product_category ?? 0,
        'id_product_image': id_product_image ?? "",
        'product_name': product_name ?? "",
        'product_brand': product_brand ?? "",
        'product_barcode': product_barcode ?? "",
        'product_quantifier': product_quantifier ?? "",
        'product_category_desc': product_category_desc ?? "",
        'product_price': product_price ?? 0,
        'product_quantity': product_quantity ?? 0,
        'product_description': product_description ?? "",
        "product_owner": product_owner_id ?? 0
      },
      "image": {
        "id_product_image": id_product_image ?? 0,
        "product_image_url":
            product_image_url ?? "", // For reasons of simplicity
        "product_ref_id": product_ref_id ?? 0
      }
    };
  }
}

class ProductCategory {
  final int product_provider_type_id;
  final String product_category_desc;
  ProductCategory(
      {required this.product_provider_type_id,
      required this.product_category_desc});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
        product_provider_type_id: json['id_product_category'] ?? 0,
        product_category_desc: json['product_category_desc'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product_provider_type': product_provider_type_id,
      'product_provider_type_desc': product_category_desc,
    };
  }
}
