class Supplier {
  final int idprovider_details_id;
  final int id_product_provider;
  final int product_provider_details_id;
  final String provider_name;
  final String provider_contact_info;
  final int product_provider_type_id;

  final double location_latitude;
  final double location_longitude;
  final String? location_name;

  Supplier(
      {required this.idprovider_details_id,
      required this.id_product_provider,
      required this.product_provider_details_id,
      required this.provider_name,
      required this.provider_contact_info,
      required this.location_latitude,
      required this.location_longitude,
      required this.location_name,
      required this.product_provider_type_id});

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
        idprovider_details_id: json['idprovider_details_id'] ?? 0,
        id_product_provider: json['id_product_provider'] ?? 0,
        product_provider_details_id: json['product_provider_details_id'] ?? 0,
        provider_name: json['product_provider_details']['provider_name'] ?? "",
        provider_contact_info:
            json['product_provider_details']['provider_contact_info'] ?? "",
        location_latitude:
            json["product_provider_location"]['location_latitude'] ?? 0.0,
        location_longitude:
            json["product_provider_location"]['location_longitude'] ?? 0.0,
        product_provider_type_id:
            json['product_provider_type']['id_product_provider_type'] ?? 0,
        location_name:
            json["product_provider_location"]['location_name'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      "supplier": {
        'idprovider_details_id': idprovider_details_id,
        'id_product_provider': id_product_provider,
        'product_provider_details_id': product_provider_details_id,
        'provider_name': provider_name,
        'provider_contact_info': provider_contact_info,
        'id_product_provider_type': product_provider_type_id,
      },
      "location": {
        'id_address': 0,
        'id_location': 0,
        'location_latitude': location_latitude,
        'location_longitude': location_longitude,
        'location_name': location_name,
      }
    };
  }
}

class Category {
  final int product_provider_type_id;
  final String product_category_desc;
  Category(
      {required this.product_provider_type_id,
      required this.product_category_desc});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        product_provider_type_id: json['id_product_provider_type'] ?? 0,
        product_category_desc: json['product_provider_type_desc'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product_category': product_provider_type_id,
    };
  }
}
