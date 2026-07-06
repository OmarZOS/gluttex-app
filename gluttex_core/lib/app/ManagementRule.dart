import 'package:gluttex_core/app/AppUser.dart';

class ManagementRule {
  final int id_management_rule;
  final int management_rule_code;
  final ProviderOrganisation? providerOrganisation;
  final String? ruleStatus;
  final ProductProvider? productProvider;
  final AppUser? appUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final bool isActive;

  ManagementRule({
    required this.id_management_rule,
    required this.management_rule_code,
    this.providerOrganisation,
    this.productProvider,
    this.appUser,
    this.ruleStatus,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.isActive = false,
  });

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
      ruleStatus: json['management_rule_status'] ?? "REJECTED",
      appUser:
          json['app_user'] != null ? AppUser.fromJson(json['app_user']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'])
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.tryParse(json['rejected_at'])
          : null,
      isActive: json['is_active'] == true ||
          (json['management_rule_status']?.toString().toUpperCase() ==
              'ACTIVE'),
    );
  }

  Map<String, dynamic> toJson(int user, int ruleCode, String? expiry) {
    return {
      "id_management_rule": id_management_rule,
      "rule_ref_org": providerOrganisation,
      "rule_ref_provider": productProvider,
      "rule_ref_user": user,
      "management_rule_code": ruleCode,
      "management_rule_status": ruleStatus,
      "management_rule_expiry": expiry,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "accepted_at": acceptedAt?.toIso8601String(),
      "rejected_at": rejectedAt?.toIso8601String(),
      "is_active": isActive,
    };
  }

  /// Creates a copy of this ManagementRule with the given fields replaced
  ManagementRule copyWith({
    int? id_management_rule,
    int? management_rule_code,
    ProviderOrganisation? providerOrganisation,
    String? ruleStatus,
    ProductProvider? productProvider,
    AppUser? appUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    bool? isActive,
  }) {
    return ManagementRule(
      id_management_rule: id_management_rule ?? this.id_management_rule,
      management_rule_code: management_rule_code ?? this.management_rule_code,
      providerOrganisation: providerOrganisation ?? this.providerOrganisation,
      ruleStatus: ruleStatus ?? this.ruleStatus,
      productProvider: productProvider ?? this.productProvider,
      appUser: appUser ?? this.appUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Creates a copy with status updated and sets acceptance/rejection timestamps
  ManagementRule copyWithStatus({
    required String newStatus,
    bool updateTimestamps = true,
  }) {
    final now = DateTime.now();
    final statusUpper = newStatus.toUpperCase();

    return copyWith(
      ruleStatus: newStatus,
      isActive: statusUpper == 'ACTIVE',
      updatedAt: now,
      acceptedAt:
          updateTimestamps && statusUpper == 'ACTIVE' ? now : acceptedAt,
      rejectedAt: updateTimestamps &&
              (statusUpper == 'REJECTED' || statusUpper == 'DECLINED')
          ? now
          : rejectedAt,
    );
  }

  /// Creates a copy marking the rule as accepted
  ManagementRule copyAsAccepted() {
    final now = DateTime.now();
    return copyWith(
      ruleStatus: 'ACTIVE',
      isActive: true,
      updatedAt: now,
      acceptedAt: now,
    );
  }

  /// Creates a copy marking the rule as rejected
  ManagementRule copyAsRejected() {
    final now = DateTime.now();
    return copyWith(
      ruleStatus: 'REJECTED',
      isActive: false,
      updatedAt: now,
      rejectedAt: now,
    );
  }

  /// Creates a copy with updated provider information
  ManagementRule copyWithProvider({
    required ProductProvider newProvider,
    ProviderOrganisation? newOrganisation,
  }) {
    return copyWith(
      productProvider: newProvider,
      providerOrganisation: newOrganisation ?? providerOrganisation,
    );
  }

  /// Creates a copy with updated user information
  ManagementRule copyWithUser(AppUser newUser) {
    return copyWith(
      appUser: newUser,
    );
  }

  /// Checks if this rule is pending
  bool get isPending => (ruleStatus?.toUpperCase() ?? 'PENDING') == 'PENDING';

  /// Checks if this rule is active
  bool get isActiveStatus => (ruleStatus?.toUpperCase() ?? '') == 'ACTIVE';

  /// Checks if this rule is rejected/declined
  bool get isRejected {
    final status = ruleStatus?.toUpperCase() ?? '';
    return status == 'REJECTED' || status == 'DECLINED';
  }

  /// Gets the display status
  String get displayStatus {
    switch (ruleStatus?.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'ACTIVE':
        return 'Active';
      case 'REJECTED':
        return 'Rejected';
      case 'DECLINED':
        return 'Declined';
      case 'EXPIRED':
        return 'Expired';
      default:
        return ruleStatus ?? 'Unknown';
    }
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.tryParse(value) ?? 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagementRule &&
          runtimeType == other.runtimeType &&
          id_management_rule == other.id_management_rule &&
          productProvider?.id_product_provider ==
              other.productProvider?.id_product_provider;

  @override
  int get hashCode => id_management_rule.hashCode;

  @override
  String toString() {
    return 'ManagementRule(id: $id_management_rule, code: $management_rule_code, '
        'status: $ruleStatus, provider: ${productProvider?.product_provider_details.provider_name}, '
        'user: ${appUser?.appUserName})';
  }
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

class ManagementRuleData {
  final List<ManagementRule> all;
  final List<ManagementRule> active;
  final List<ManagementRule> pending;
  final ManagementRule? activeForSupplier;
  final ManagementRule? pendingForSupplier;

  ManagementRuleData({
    required this.all,
    required this.active,
    required this.pending,
    required this.activeForSupplier,
    required this.pendingForSupplier,
  });
}
