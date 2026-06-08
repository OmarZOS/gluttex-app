import 'dart:developer';

class Organisation {
  final int id_provider_organisation;
  final String provider_organisation_name;
  final String provider_organisation_desc;

  Organisation({
    required this.id_provider_organisation,
    required this.provider_organisation_name,
    required this.provider_organisation_desc,
  });

  factory Organisation.empty() => Organisation(
        id_provider_organisation: 0,
        provider_organisation_name: "",
        provider_organisation_desc: "",
      );

  factory Organisation.fromJson(Map<String, dynamic> json) {
    return Organisation(
      id_provider_organisation: json['idprovider_organisation'] ?? 0,
      provider_organisation_name: json["provider_organisation_name"] ?? "",
      provider_organisation_desc: json["provider_organisation_desc"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organisation": {
        'id_provider_organisation': id_provider_organisation,
        'provider_organisation_desc': provider_organisation_desc,
        'provider_organisation_name': provider_organisation_name,
      }
    };
  }
}
