import 'dart:developer';

class Supplier {
  final int idProviderDetails;
  final int idProductProvider;
  final int productProviderDetailsId;
  final String providerName;
  final String providerContactInfo;
  final int productProviderTypeId;
  final double locationLatitude;
  final double locationLongitude;
  final String? locationName;

  Supplier({
    required this.idProviderDetails,
    required this.idProductProvider,
    required this.productProviderDetailsId,
    required this.providerName,
    required this.providerContactInfo,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.locationName,
    required this.productProviderTypeId,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    double longitude = 0.0, latitude = 0.0;

    try {
      if (json["product_provider_location"]?["position_wkt"] != null) {
        var point = json["product_provider_location"]["position_wkt"]
            .replaceAll("POINT(", "")
            .replaceAll(")", "");
        List<String> coords = point.split(" ");
        if (coords.length == 2) {
          longitude = double.tryParse(coords[0]) ?? 0.0;
          latitude = double.tryParse(coords[1]) ?? 0.0;
        }
      }
    } catch (e) {
      log("Error parsing WKT: $e");
    }

    return Supplier(
      idProviderDetails: json['idprovider_details_id'] ?? 0,
      idProductProvider: json['id_product_provider'] ?? 0,
      productProviderDetailsId: json['product_provider_details_id'] ?? 0,
      providerName: json['product_provider_details']?['provider_name'] ?? "",
      providerContactInfo:
          json['product_provider_details']?['provider_contact_info'] ?? "",
      locationLatitude: latitude,
      locationLongitude: longitude,
      productProviderTypeId:
          json['product_provider_type']?['id_product_provider_type'] ?? 0,
      locationName: json["product_provider_location"]?['location_name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "supplier": {
        'id_provider_details': idProviderDetails,
        'id_product_provider': idProductProvider,
        'product_provider_details_id': productProviderDetailsId,
        'provider_name': providerName,
        'provider_contact_info': providerContactInfo,
        'id_product_provider_type': productProviderTypeId,
      },
      "location": {
        'id_address': 0,
        'id_location': 0,
        'location_latitude': locationLatitude,
        'location_longitude': locationLongitude,
        'location_name': locationName,
      }
    };
  }
}

class SupplierCategory {
  final int productProviderTypeId;
  final String productCategoryDesc;

  SupplierCategory({
    required this.productProviderTypeId,
    required this.productCategoryDesc,
  });

  factory SupplierCategory.fromJson(Map<String, dynamic> json) {
    return SupplierCategory(
      productProviderTypeId: json['id_product_provider_type'] ?? 0,
      productCategoryDesc: json['product_provider_type_desc'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product_provider_type': productProviderTypeId,
      'product_provider_type_desc': productCategoryDesc,
    };
  }
}
