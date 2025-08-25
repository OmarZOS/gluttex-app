import 'dart:developer';

import 'package:gluttex_core/app/GluttexImage.dart';

class Supplier {
  int idProviderDetails;
  int idProductProvider;
  int productProviderDetailsId;
  int productProviderOwnerId;
  int location_address_id;
  int id_location;
  final String providerName;
  final String providerContactInfo;
  int productProviderTypeId;
  final String address_street;
  final String address_city;
  final String address_postal_code;
  final String address_country;

  int id_provider_organisation;
  final String provider_organisation_name;
  final String provider_organisation_desc;

  final double locationLatitude;
  final double locationLongitude;
  final String? locationName;
  String? supplier_image_url;
  int? supplier_image_id;

  GluttexImage? supplier_image;

  Supplier({
    required this.idProviderDetails,
    required this.idProductProvider,
    required this.productProviderDetailsId,
    required this.providerName,
    required this.providerContactInfo,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.locationName,
    required this.id_location,
    required this.productProviderOwnerId,
    required this.productProviderTypeId,
    required this.supplier_image_url,
    required this.supplier_image_id,
    required this.id_provider_organisation,
    required this.provider_organisation_name,
    required this.provider_organisation_desc,
    required this.location_address_id,
    required this.address_street,
    required this.address_city,
    required this.address_postal_code,
    required this.address_country,
  });

  factory Supplier.empty() => Supplier(
      idProviderDetails: 0,
      idProductProvider: 0,
      productProviderDetailsId: 0,
      productProviderOwnerId: 0,
      productProviderTypeId: 0,
      supplier_image_id: 0,
      location_address_id: 0,
      id_location: 0,
      id_provider_organisation: 0,
      providerName: "",
      providerContactInfo: "",
      locationLatitude: 0.0,
      locationLongitude: 0.0,
      locationName: "",
      supplier_image_url: "",
      provider_organisation_name: "",
      provider_organisation_desc: "",
      address_street: "",
      address_city: "",
      address_postal_code: "",
      address_country: "");

  factory Supplier.fromJson(Map<String, dynamic> json) {
    double longitude = 0.0, latitude = 0.0;
    String? imageUrl;
    int imageId = 0;
    try {
      if (json["product_provider_location"]?["position_wkt"] != null) {
        var point = json["product_provider_location"]?["position_wkt"]
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

    if (json['provider_image'] != null && json['provider_image'] is List) {
      if (json['provider_image']?.isNotEmpty) {
        imageId = json['provider_image'].last["id_provider_image"] ?? 0;
        imageUrl = json['provider_image'].last["provider_image_url"];
      }
    }
    String organisation_name = "";
    String organisation_desc = "";

    if (json['product_provider_org'] != null) {
      organisation_name =
          json['product_provider_org']?["provider_organisation_name"];
      organisation_desc =
          json['product_provider_org']?["provider_organisation_desc"];
    }

    int _location_address_id = 0;
    String _address_street = "";
    String _address_city = "";
    String _address_postal_code = "";
    String _address_country = "";
    if (json["product_provider_location"]?["location_address"] != null) {
      _location_address_id = json["product_provider_location"]
              ?["location_address"]?["id_address"] ??
          0;
      _address_street = json["product_provider_location"]?["location_address"]
              ["address_street"] ??
          "";
      _address_city = json["product_provider_location"]?["location_address"]
              ?["address_city"] ??
          "";
      _address_postal_code = json["product_provider_location"]
              ["location_address"]?["address_postal_code"] ??
          "";
      _address_country = json["product_provider_location"]?["location_address"]
              ?["address_country"] ??
          "";
    }

    return Supplier(
      idProviderDetails: json['idprovider_details_id'] ?? 0,
      idProductProvider: json['id_product_provider'] ?? 0,
      id_provider_organisation: json['product_provider_org_id'] ?? 0,
      provider_organisation_name: organisation_name,
      provider_organisation_desc: organisation_desc,
      productProviderDetailsId: json['product_provider_details_id'] ?? 0,
      providerName: json['product_provider_details']?['provider_name'] ?? "",
      providerContactInfo:
          json['product_provider_details']?['provider_contact_info'] ?? "",
      productProviderOwnerId: json['product_provider_owner'] ?? 0,
      locationLatitude: latitude,
      locationLongitude: longitude,
      productProviderTypeId: json['product_provider_type_id'] ?? 0,
      location_address_id: _location_address_id,
      address_street: _address_street,
      address_city: _address_city,
      address_postal_code: _address_postal_code,
      address_country: _address_country,
      locationName: json["product_provider_location"]?['location_name'] ?? "",
      id_location: json["product_provider_location_id"] ?? "",
      supplier_image_url: imageUrl,
      supplier_image_id: imageId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "supplier": {
        'id_product_provider': idProductProvider,
        "id_provider_owner": productProviderOwnerId,
        "idprovider_details_id": productProviderDetailsId,
        'id_product_provider_type': productProviderTypeId,
        'id_provider_organisation': id_provider_organisation,
        'provider_organisation_desc': provider_organisation_desc,
        'provider_organisation_name': provider_organisation_name,
        "product_provider_type_desc": "string",
        'provider_name': providerName,
        'provider_contact_info': providerContactInfo,
      },
      "image": {
        "id_provider_image": supplier_image_id ?? 0,
        "provider_image_url": supplier_image_url,
        "provider_ref_id": idProductProvider
      },
      "location": {
        'id_location': id_location,
        'location_latitude': locationLatitude,
        'location_longitude': locationLongitude,
        'location_name': locationName,
        "location_address_id": location_address_id,
        'id_address': location_address_id,
        "address_street": address_street,
        "address_city": address_city,
        "address_postal_code": address_postal_code,
        "address_country": address_country,
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
