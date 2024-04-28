class Supplier {
  final int idprovider_details_id;
  final int id_product_provider;
  final int product_provider_details_id;
  final String provider_name;
  final String provider_contact_info;
  final String product_provider_type_desc;

  Supplier(
      {required this.idprovider_details_id,
      required this.id_product_provider,
      required this.product_provider_details_id,
      required this.provider_name,
      required this.provider_contact_info,
      required this.product_provider_type_desc});

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      idprovider_details_id: json['idprovider_details_id'] as int,
      id_product_provider: json['id_product_provider'] as int,
      product_provider_details_id: json['product_provider_details_id'] as int,
      provider_name: json['provider_name'] as String,
      provider_contact_info: json['provider_contact_info'] as String,
      product_provider_type_desc: json['product_provider_type_desc'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idprovider_details_id': idprovider_details_id,
      'id_product_provider': id_product_provider,
      'product_provider_details_id': product_provider_details_id,
      'provider_name': provider_name,
      'provider_contact_info': provider_contact_info,
      'product_provider_type_desc': product_provider_type_desc,
    };
  }
}
