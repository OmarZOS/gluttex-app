import 'package:gluttex_core/app/AppUser.dart';

class ManagementRule {
  final int id_management_rule;
  final int management_rule_code;
  final ProviderOrganisation? providerOrganisation;
  final String? ruleStatus;
  final ProductProvider? productProvider;
  final AppUser? appUser;

  ManagementRule(
      {required this.id_management_rule,
      required this.management_rule_code,
      this.providerOrganisation,
      this.productProvider,
      this.appUser,
      this.ruleStatus});

  factory ManagementRule.fromJson(Map<String, dynamic> json) {
    return ManagementRule(
      id_management_rule: _parseInt(json['id_management_rule']),
      management_rule_code: _parseInt(json['management_rule_code']),
      providerOrganisation: json['provider_organisation'] != null
          ? ProviderOrganisation.fromJson(json['provider_organisation'])
          : null,
      productProvider: json['product_provider'] != null
          ? ProductProvider.fromJson(json['product_provider'])
          : null,
      ruleStatus: json['management_rule_status'] ?? "PENDING",
      appUser:
          json['app_user'] != null ? AppUser.fromJson(json['app_user']) : null,
    );
  }

  Map<String, dynamic> toJson(int user, int ruleCode, String? expiry) {
    return {
      "id_management_rule": 0,
      "rule_ref_org": providerOrganisation,
      "rule_ref_provider": productProvider,
      "rule_ref_user": user,
      "management_rule_code": ruleCode,
      "management_rule_status": ruleStatus,
      "management_rule_expiry": expiry
    };
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.tryParse(value) ?? 0;
}

class ProviderOrganisation {
  final String provider_organisation_name;
  final String provider_organisation_desc;
  final int idprovider_organisation;

  ProviderOrganisation({
    required this.provider_organisation_name,
    required this.provider_organisation_desc,
    required this.idprovider_organisation,
  });

  factory ProviderOrganisation.fromJson(Map<String, dynamic> json) {
    return ProviderOrganisation(
      provider_organisation_name:
          json['provider_organisation_name']?.toString() ?? '',
      provider_organisation_desc:
          json['provider_organisation_desc']?.toString() ?? '',
      idprovider_organisation:
          (json['idprovider_organisation'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProductProvider {
  final int product_provider_type_id;
  final int product_provider_location_id;
  final int product_provider_org_id;
  final int id_product_provider;
  final int product_provider_details_id;
  final int product_provider_owner;
  final ProductProviderDetails product_provider_details;

  ProductProvider({
    required this.product_provider_type_id,
    required this.product_provider_location_id,
    required this.product_provider_org_id,
    required this.id_product_provider,
    required this.product_provider_details_id,
    required this.product_provider_owner,
    required this.product_provider_details,
  });

  factory ProductProvider.fromJson(Map<String, dynamic> json) {
    return ProductProvider(
      product_provider_type_id:
          (json['product_provider_type_id'] as num?)?.toInt() ?? 0,
      product_provider_location_id:
          (json['product_provider_location_id'] as num?)?.toInt() ?? 0,
      product_provider_org_id:
          (json['product_provider_org_id'] as num?)?.toInt() ?? 0,
      id_product_provider: (json['id_product_provider'] as num?)?.toInt() ?? 0,
      product_provider_details_id:
          (json['product_provider_details_id'] as num?)?.toInt() ?? 0,
      product_provider_owner:
          (json['product_provider_owner'] as num?)?.toInt() ?? 0,
      product_provider_details: ProductProviderDetails.fromJson(
        json['product_provider_details'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class ProductProviderDetails {
  final String provider_name;
  final int idprovider_details_id;
  final String provider_contact_info;

  ProductProviderDetails({
    required this.provider_name,
    required this.idprovider_details_id,
    required this.provider_contact_info,
  });

  factory ProductProviderDetails.fromJson(Map<String, dynamic> json) {
    return ProductProviderDetails(
      provider_name: json['provider_name']?.toString() ?? '',
      idprovider_details_id:
          (json['idprovider_details_id'] as num?)?.toInt() ?? 0,
      provider_contact_info: json['provider_contact_info']?.toString() ?? '',
    );
  }
}
