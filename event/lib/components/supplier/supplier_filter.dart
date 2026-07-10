import 'package:flutter/material.dart';

@immutable
class SupplierFilter {
  final String? name;
  final int? organisationId;
  final int? ownerId;
  final double? minRating;
  final List<int>? types;
  final String? status;
  final bool? hasLocation;
  final bool? isActive;

  const SupplierFilter({
    this.name,
    this.organisationId,
    this.ownerId,
    this.minRating,
    this.types,
    this.status,
    this.hasLocation,
    this.isActive,
  });

  SupplierFilter copyWith({
    String? name,
    int? organisationId,
    int? ownerId,
    double? minRating,
    List<int>? types,
    String? status,
    bool? hasLocation,
    bool? isActive,
  }) {
    return SupplierFilter(
      name: name ?? this.name,
      organisationId: organisationId ?? this.organisationId,
      ownerId: ownerId ?? this.ownerId,
      minRating: minRating ?? this.minRating,
      types: types ?? this.types,
      status: status ?? this.status,
      hasLocation: hasLocation ?? this.hasLocation,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isEmpty =>
      name == null &&
      organisationId == null &&
      ownerId == null &&
      minRating == null &&
      (types == null || types!.isEmpty) &&
      status == null &&
      hasLocation == null &&
      isActive == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierFilter &&
        other.name == name &&
        other.organisationId == organisationId &&
        other.ownerId == ownerId &&
        other.minRating == minRating &&
        other.types == types &&
        other.status == status &&
        other.hasLocation == hasLocation &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(
        name,
        organisationId,
        ownerId,
        minRating,
        types,
        status,
        hasLocation,
        isActive,
      );
}
