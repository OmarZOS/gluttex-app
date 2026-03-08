import 'dart:convert';

class ProvidedService {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final int productProviderId;
  final double basePrice;
  final double finalPrice;
  final int actualDuration; // in minutes
  final ProvidedServicePricingConfig pricingConfig;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<ServiceResourceRequirement> resourceRequirements;
  final List<ServiceStaffRequirement> staffRequirements;

  ProvidedService({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.productProviderId,
    required this.basePrice,
    required this.finalPrice,
    required this.actualDuration,
    required this.pricingConfig,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.resourceRequirements = const [],
    this.staffRequirements = const [],
  });

  // Get discount percentage
  double get discountPercentage {
    if (basePrice == 0) return 0;
    return ((basePrice - finalPrice) / basePrice * 100);
  }

  // Duration in hours:minutes format
  String get durationFormatted {
    final hours = actualDuration ~/ 60;
    final minutes = actualDuration % 60;
    if (hours == 0) return '${minutes}min';
    return '${hours}h ${minutes}min';
  }

  // Calculate total resource cost
  double get totalResourceCost {
    return resourceRequirements.fold(
      0.0,
      (total, requirement) =>
          total + (requirement.costPerUnit * requirement.quantity),
    );
  }

  // Calculate total staff cost
  double get totalStaffCost {
    return staffRequirements.fold(
      0.0,
      (total, requirement) =>
          total + (requirement.hourlyRate * requirement.allocatedHours),
    );
  }

  // Calculate total cost (resources + staff)
  double get totalCost {
    return totalResourceCost + totalStaffCost;
  }

  // Calculate profit margin
  double get profitMargin {
    if (finalPrice == 0) return 0;
    return ((finalPrice - totalCost) / finalPrice * 100);
  }

  factory ProvidedService.empty() {
    return ProvidedService(
        id: 0,
        name: '',
        description: '',
        categoryId: 1,
        productProviderId: 1,
        basePrice: 0.0,
        finalPrice: 0.0,
        actualDuration: 0,
        pricingConfig: ProvidedServicePricingConfig(),
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  factory ProvidedService.fromJson(Map<String, dynamic> json) {
    // Parse requirements if they exist
    final List<ServiceResourceRequirement> resourceRequirements = [];
    if (json['service_resource_requirement'] != null) {
      final resourcesJson = json['service_resource_requirement'] as List;
      resourceRequirements.addAll(
        resourcesJson.map(
          (resourceJson) => ServiceResourceRequirement.fromJson(resourceJson),
        ),
      );
    }

    final List<ServiceStaffRequirement> staffRequirements = [];
    if (json['service_staff_requirement'] != null) {
      final staffJson = json['service_staff_requirement'] as List;
      staffRequirements.addAll(
        staffJson.map(
          (staffJson) => ServiceStaffRequirement.fromJson(staffJson),
        ),
      );
    }

    // Handle pricing config (could be string or map)
    final pricingConfigJson = json['provided_service_pricing_config'];
    ProvidedServicePricingConfig pricingConfig;

    if (pricingConfigJson is String) {
      // Parse JSON string
      try {
        final parsed = jsonDecode(pricingConfigJson) as Map<String, dynamic>;
        pricingConfig = ProvidedServicePricingConfig.fromJson(parsed);
      } catch (e) {
        // If parsing fails, create empty config
        pricingConfig = ProvidedServicePricingConfig();
      }
    } else if (pricingConfigJson is Map<String, dynamic>) {
      pricingConfig = ProvidedServicePricingConfig.fromJson(pricingConfigJson);
    } else {
      pricingConfig = ProvidedServicePricingConfig();
    }

    // Convert actualDuration from double to int
    final actualDurationValue = json['provided_service_actual_duration'];
    final int actualDuration;

    if (actualDurationValue is double) {
      actualDuration = actualDurationValue.toInt();
    } else if (actualDurationValue is int) {
      actualDuration = actualDurationValue;
    } else {
      actualDuration = 0; // default
    }

    return ProvidedService(
      id: json['provided_service_id'] as int,
      name: json['provided_service_name'] as String,
      description: json['provided_service_description'] as String,
      categoryId: json['provided_service_category_id'] as int,
      productProviderId: json['provided_service_product_provider_id'] as int,
      basePrice: (json['provided_service_base_price'] as num).toDouble(),
      finalPrice: (json['provided_service_final_price'] as num).toDouble(),
      actualDuration: actualDuration, // Use converted value
      pricingConfig: pricingConfig,
      isActive: json['provided_service_is_active'] == 1,
      createdAt: DateTime.parse(json['provided_service_created_at'] as String),
      updatedAt: DateTime.parse(json['provided_service_updated_at'] as String),
      deletedAt: json['provided_service_deleted_at'] != null
          ? DateTime.parse(json['provided_service_deleted_at'] as String)
          : null,
      resourceRequirements: resourceRequirements,
      staffRequirements: staffRequirements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provided_service_id': id,
      'provided_service_name': name,
      'provided_service_description': description,
      'provided_service_category_id': categoryId,
      'provided_service_product_provider_id': productProviderId,
      'provided_service_base_price': basePrice,
      'provided_service_final_price': finalPrice,
      'provided_service_actual_duration': actualDuration,
      'provided_service_pricing_config': pricingConfig.toJson(),
      'provided_service_is_active': isActive ? 1 : 0,
      'provided_service_created_at': createdAt.toIso8601String(),
      'provided_service_updated_at': updatedAt.toIso8601String(),
      'provided_service_deleted_at': deletedAt?.toIso8601String(),
      'service_resource_requirement':
          resourceRequirements.map((r) => r.toJson()).toList(),
      'service_staff_requirement':
          staffRequirements.map((s) => s.toJson()).toList(),
    };
  }

  ProvidedService copyWith({
    int? id,
    String? name,
    String? description,
    int? categoryId,
    int? productProviderId,
    double? basePrice,
    double? finalPrice,
    int? actualDuration,
    ProvidedServicePricingConfig? pricingConfig,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<ServiceResourceRequirement>? resourceRequirements,
    List<ServiceStaffRequirement>? staffRequirements,
  }) {
    return ProvidedService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      productProviderId: productProviderId ?? this.productProviderId,
      basePrice: basePrice ?? this.basePrice,
      finalPrice: finalPrice ?? this.finalPrice,
      actualDuration: actualDuration ?? this.actualDuration,
      pricingConfig: pricingConfig ?? this.pricingConfig,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      resourceRequirements: resourceRequirements ?? this.resourceRequirements,
      staffRequirements: staffRequirements ?? this.staffRequirements,
    );
  }

  @override
  String toString() {
    return 'ProvidedService(id: $id, name: $name, category: $categoryId, price: DZD$finalPrice, resources: ${resourceRequirements.length}, staff: ${staffRequirements.length})';
  }
}

// Resource Requirement Model
class ServiceResourceRequirement {
  final int id;
  final String name;
  final String type;
  final double quantity;
  final bool isConsumable;
  final int? productRef; // Reference to product ID if exists
  final int serviceId;
  final double costPerUnit;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceResourceRequirement({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.isConsumable,
    this.productRef,
    required this.serviceId,
    required this.costPerUnit,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate total cost for this requirement
  double get totalCost => costPerUnit * quantity;

  factory ServiceResourceRequirement.fromJson(Map<String, dynamic> json) {
    return ServiceResourceRequirement(
      id: json['service_resource_requirement_id'] as int,
      name: json['service_resource_requirement_name'] as String,
      type: json['service_resource_requirement_type'] as String,
      quantity:
          (json['service_resource_requirement_quantity'] as num).toDouble(),
      isConsumable: json['service_resource_requirement_is_consumable'] == 1,
      productRef: json['service_resource_requirement_product_ref'] as int?,
      serviceId: json['service_resource_requirement_service_id'] as int,
      costPerUnit: (json['service_resource_requirement_cost_per_unit'] as num)
          .toDouble(),
      notes: json['service_resource_requirement_notes'] as String?,
      createdAt:
          DateTime.parse(json['service_resource_requirement_created_at']),
      updatedAt:
          DateTime.parse(json['service_resource_requirement_updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_resource_requirement_id': id,
      'service_resource_requirement_name': name,
      'service_resource_requirement_type': type,
      'service_resource_requirement_quantity': quantity,
      'service_resource_requirement_is_consumable': isConsumable ? 1 : 0,
      'service_resource_requirement_product_ref': productRef,
      'service_resource_requirement_service_id': serviceId,
      'service_resource_requirement_cost_per_unit': costPerUnit,
      'service_resource_requirement_notes': notes,
      'service_resource_requirement_created_at': createdAt.toIso8601String(),
      'service_resource_requirement_updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Staff Requirement Model
class ServiceStaffRequirement {
  final int id;
  final int serviceId;
  final int minCount;
  final int maxCount;
  final String role;
  final double allocatedHours;
  final double hourlyRate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceStaffRequirement({
    required this.id,
    required this.serviceId,
    required this.minCount,
    required this.maxCount,
    required this.role,
    required this.allocatedHours,
    required this.hourlyRate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate cost for minimum staff count
  double get minCost => hourlyRate * allocatedHours * minCount;

  // Calculate cost for maximum staff count
  double get maxCost => hourlyRate * allocatedHours * maxCount;

  // Calculate average cost
  double get averageCost {
    final avgCount = (minCount + maxCount) / 2;
    return hourlyRate * allocatedHours * avgCount;
  }

  factory ServiceStaffRequirement.fromJson(Map<String, dynamic> json) {
    return ServiceStaffRequirement(
      id: json['service_staff_requirement_id'] as int,
      serviceId: json['service_staff_requirement_service_id'] as int,
      minCount: json['service_staff_requirement_min_count'] as int,
      maxCount: json['service_staff_requirement_max_count'] as int,
      role: json['service_staff_requirement_role'] as String,
      allocatedHours:
          (json['service_staff_requirement_allocated_hours'] as num).toDouble(),
      hourlyRate:
          (json['service_staff_requirement_hourly_rate'] as num).toDouble(),
      notes: json['service_staff_requirement_notes'] as String?,
      createdAt: DateTime.parse(json['service_staff_requirement_created_at']),
      updatedAt: DateTime.parse(json['service_staff_requirement_updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_staff_requirement_id': id,
      'service_staff_requirement_service_id': serviceId,
      'service_staff_requirement_min_count': minCount,
      'service_staff_requirement_max_count': maxCount,
      'service_staff_requirement_role': role,
      'service_staff_requirement_allocated_hours': allocatedHours,
      'service_staff_requirement_hourly_rate': hourlyRate,
      'service_staff_requirement_notes': notes,
      'service_staff_requirement_created_at': createdAt.toIso8601String(),
      'service_staff_requirement_updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Pricing Config remains the same as your original
class ProvidedServicePricingConfig {
  final String? recommendedAge;
  final String? recommendedFrequency;
  final String? ageGroup;
  final String? sampleType;
  final bool? specialistConsultation;
  final bool? governmentFunded;
  final bool? consultationIncluded;
  final bool? digitalImaging;
  final List<String>? materialOptions;
  final List<String>? includes;
  final Map<String, dynamic>? additionalConfig;

  ProvidedServicePricingConfig({
    this.recommendedAge,
    this.recommendedFrequency,
    this.ageGroup,
    this.sampleType,
    this.specialistConsultation,
    this.governmentFunded,
    this.consultationIncluded,
    this.digitalImaging,
    this.materialOptions,
    this.includes,
    this.additionalConfig,
  });

  factory ProvidedServicePricingConfig.fromJson(Map<String, dynamic> json) {
    return ProvidedServicePricingConfig(
      recommendedAge: json['recommended_age'] as String?,
      recommendedFrequency: json['recommended_frequency'] as String?,
      ageGroup: json['age_group'] as String?,
      sampleType: json['sample_type'] as String?,
      specialistConsultation: json['specialist_consultation'] as bool?,
      governmentFunded: json['government_funded'] as bool?,
      consultationIncluded: json['consultation_included'] as bool?,
      digitalImaging: json['digital_imaging'] as bool?,
      materialOptions: json['material_options'] != null
          ? List<String>.from(json['material_options'] as List)
          : null,
      includes: json['includes'] != null
          ? List<String>.from(json['includes'] as List)
          : null,
      additionalConfig: json.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (recommendedAge != null) json['recommended_age'] = recommendedAge;
    if (recommendedFrequency != null)
      json['recommended_frequency'] = recommendedFrequency;
    if (ageGroup != null) json['age_group'] = ageGroup;
    if (sampleType != null) json['sample_type'] = sampleType;
    if (specialistConsultation != null)
      json['specialist_consultation'] = specialistConsultation;
    if (governmentFunded != null) json['government_funded'] = governmentFunded;
    if (consultationIncluded != null)
      json['consultation_included'] = consultationIncluded;
    if (digitalImaging != null) json['digital_imaging'] = digitalImaging;
    if (materialOptions != null) json['material_options'] = materialOptions;
    if (includes != null) json['includes'] = includes;

    if (additionalConfig != null) {
      json.addAll(additionalConfig!);
    }

    return json;
  }

  @override
  String toString() {
    return 'PricingConfig(${toJson().toString()})';
  }
}
