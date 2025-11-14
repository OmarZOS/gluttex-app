class IProduct {
  final int? idIproduct;
  final String iproductBarcode;
  final String iproductName;
  final String iproductBrand;
  final double iproductEstimatedPriceDA;
  final String iproductGlutenStatus;
  final String iproductSource;
  final DateTime? iproductLastPriceUpdate;
  final String? iproductImageUrl;
  final DateTime iproductCreatedAt;
  final DateTime iproductUpdatedAt;
  final String iproductModelName;

// Helper method to parse price
  static double _parsePrice(dynamic priceData) {
    if (priceData == null) return 0.0;

    if (priceData is num) {
      return priceData.toDouble();
    }

    if (priceData is String) {
      // Remove currency symbols and whitespace
      final cleaned =
          priceData.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }

    return 0.0;
  }

  IProduct({
    this.idIproduct,
    required this.iproductBarcode,
    required this.iproductName,
    required this.iproductBrand,
    required this.iproductEstimatedPriceDA,
    required this.iproductGlutenStatus,
    required this.iproductSource,
    this.iproductLastPriceUpdate,
    this.iproductImageUrl,
    required this.iproductCreatedAt,
    required this.iproductUpdatedAt,
    required this.iproductModelName,
  });

  // Helper method to validate gluten status
  static String _validateGlutenStatus(String status) {
    const validStatuses = [
      'gluten_free',
      'contains_gluten',
      'may_contain_gluten',
      'unknown',
    ];

    final lowerStatus = status.toLowerCase().trim();

    // Map common variations to standard values
    final statusMap = {
      'free': 'gluten_free',
      'glutenfree': 'gluten_free',
      'sans gluten': 'gluten_free',
      'without gluten': 'gluten_free',
      'has gluten': 'contains_gluten',
      'with gluten': 'contains_gluten',
      'contient du gluten': 'contains_gluten',
      'may contain': 'may_contain_gluten',
      'traces': 'may_contain_gluten',
      'cross contamination': 'may_contain_gluten',
    };

    // Check if it's a valid status
    if (validStatuses.contains(lowerStatus)) {
      return lowerStatus;
    }

    // Check if it's a mapped variation
    if (statusMap.containsKey(lowerStatus)) {
      return statusMap[lowerStatus]!;
    }

    // Check if it contains any valid status
    for (final validStatus in validStatuses) {
      if (lowerStatus.contains(validStatus)) {
        return validStatus;
      }
    }

    return 'unknown';
  }

  factory IProduct.fromPromptResponse({
    required Map<String, dynamic> promptJson,
    required String barcode,
    String? modelName,
    String? imageUrl,
  }) {
    try {
      // Validate barcode
      if (barcode.isEmpty) {
        throw ArgumentError('Barcode cannot be empty');
      }

      // Extract and clean data
      final extractedData = _extractProductData(promptJson);

      final now = DateTime.now();

      return IProduct(
        idIproduct: null,
        iproductBarcode: barcode,
        iproductName: extractedData['name']!,
        iproductBrand: extractedData['brand']!,
        iproductEstimatedPriceDA: extractedData['price']!,
        iproductGlutenStatus: extractedData['gluten_status']!,
        iproductSource: extractedData['source']!,
        iproductLastPriceUpdate: now,
        iproductImageUrl: imageUrl,
        iproductCreatedAt: now,
        iproductUpdatedAt: now,
        iproductModelName: modelName ?? 'gemini-ai',
      );
    } catch (e) {
      throw FormatException(
          'Failed to create IProduct from prompt response: $e');
    }
  }

  static Map<String, dynamic> _extractProductData(Map<String, dynamic> json) {
    // Name extraction with fallback
    final name = _extractName(json);

    // Brand extraction with fallback
    final brand = _extractBrand(json, name);

    // Price extraction
    final price = _extractPrice(json);

    // Gluten status extraction
    final glutenStatus = _extractGlutenStatus(json);

    // Source extraction
    final source = json['source']?.toString() ?? 'ai_generated';

    return {
      'name': name,
      'brand': brand,
      'price': price,
      'gluten_status': glutenStatus,
      'source': source,
    };
  }

  static String _extractName(Map<String, dynamic> json) {
    final name = json['name']?.toString();
    if (name != null && name.isNotEmpty && name != 'Unknown') {
      return name;
    }

    // Try product_name as fallback
    final productName = json['product_name']?.toString();
    if (productName != null && productName.isNotEmpty) {
      return productName;
    }

    return 'Unknown Product';
  }

  static String _extractBrand(Map<String, dynamic> json, String productName) {
    final brand = json['brand']?.toString();
    if (brand != null && brand.isNotEmpty && brand != 'Unknown') {
      return brand;
    }

    // Try to extract brand from product name (e.g., "Coca Cola" -> "Coca Cola")
    if (productName.contains(' ')) {
      final words = productName.split(' ');
      if (words.length > 1) {
        return words.first; // Use first word as brand
      }
    }

    return 'Unknown Brand';
  }

  static double _extractPrice(Map<String, dynamic> json) {
    // Try multiple price fields
    final priceFields = [
      'estimated_price_DA',
      'price_da',
      'price',
      'estimated_price',
    ];

    for (final field in priceFields) {
      final value = json[field];
      if (value != null) {
        final parsed = _parsePrice(value);
        if (parsed > 0) return parsed;
      }
    }

    return 0.0;
  }

  static String _extractGlutenStatus(Map<String, dynamic> json) {
    final glutenFields = [
      'gluten_status',
      'gluten_tolerability',
      'gluten',
      'gluten_content',
    ];

    for (final field in glutenFields) {
      final value = json[field]?.toString();
      if (value != null && value.isNotEmpty) {
        final validated = _validateGlutenStatus(value);
        if (validated != 'unknown') {
          return validated;
        }
      }
    }

    return 'unknown';
  }

  // Factory constructor from JSON
  factory IProduct.fromJson(Map<String, dynamic> json) {
    return IProduct(
      idIproduct: json['id_iproduct'] as int?,
      iproductBarcode: json['iproduct_barcode'] as String? ?? '',
      iproductName: json['iproduct_name'] as String? ?? '',
      iproductBrand: json['iproduct_brand'] as String? ?? '',
      iproductEstimatedPriceDA:
          (json['iproduct_estimated_price_DA'] as num?)?.toDouble() ?? 0.0,
      iproductGlutenStatus:
          json['iproduct_gluten_status'] as String? ?? 'unknown',
      iproductSource: json['iproduct_source'] as String? ?? '',
      iproductLastPriceUpdate: json['iproduct_last_price_update'] != null
          ? DateTime.parse(json['iproduct_last_price_update'] as String)
          : null,
      iproductImageUrl: json['iproduct_image_url'] as String?,
      iproductCreatedAt: DateTime.parse(json['iproduct_created_at'] as String),
      iproductUpdatedAt: DateTime.parse(json['iproduct_updated_at'] as String),
      iproductModelName: json['iproduct_model_name'] as String? ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (idIproduct != null) 'id_iproduct': idIproduct,
      'iproduct_barcode': iproductBarcode,
      'iproduct_name': iproductName,
      'iproduct_brand': iproductBrand,
      'iproduct_estimated_price_DA': iproductEstimatedPriceDA,
      'iproduct_gluten_status': iproductGlutenStatus,
      'iproduct_source': iproductSource,
      'iproduct_last_price_update': iproductLastPriceUpdate?.toIso8601String(),
      'iproduct_image_url': iproductImageUrl,
      'iproduct_created_at': iproductCreatedAt.toIso8601String(),
      'iproduct_updated_at': iproductUpdatedAt.toIso8601String(),
      'iproduct_model_name': iproductModelName,
    };
  }

  // Copy with method for immutability
  IProduct copyWith({
    int? idIproduct,
    String? iproductBarcode,
    String? iproductName,
    String? iproductBrand,
    double? iproductEstimatedPriceDA,
    String? iproductGlutenStatus,
    String? iproductSource,
    DateTime? iproductLastPriceUpdate,
    String? iproductImageUrl,
    DateTime? iproductCreatedAt,
    DateTime? iproductUpdatedAt,
    String? iproductModelName,
  }) {
    return IProduct(
      idIproduct: idIproduct ?? this.idIproduct,
      iproductBarcode: iproductBarcode ?? this.iproductBarcode,
      iproductName: iproductName ?? this.iproductName,
      iproductBrand: iproductBrand ?? this.iproductBrand,
      iproductEstimatedPriceDA:
          iproductEstimatedPriceDA ?? this.iproductEstimatedPriceDA,
      iproductGlutenStatus: iproductGlutenStatus ?? this.iproductGlutenStatus,
      iproductSource: iproductSource ?? this.iproductSource,
      iproductLastPriceUpdate:
          iproductLastPriceUpdate ?? this.iproductLastPriceUpdate,
      iproductImageUrl: iproductImageUrl ?? this.iproductImageUrl,
      iproductCreatedAt: iproductCreatedAt ?? this.iproductCreatedAt,
      iproductUpdatedAt: iproductUpdatedAt ?? this.iproductUpdatedAt,
      iproductModelName: iproductModelName ?? this.iproductModelName,
    );
  }

  // Helper methods
  bool get isGlutenFree => iproductGlutenStatus == 'gluten_free';
  bool get containsGluten => iproductGlutenStatus == 'contains_gluten';
  bool get mayContainGluten => iproductGlutenStatus == 'may_contain_gluten';
  bool get hasUnknownGlutenStatus => iproductGlutenStatus == 'unknown';

  // Price formatting
  String get formattedPrice =>
      '${iproductEstimatedPriceDA.toStringAsFixed(2)} DA';

  // Check if price is recent (within 30 days)
  bool get isPriceRecent {
    if (iproductLastPriceUpdate == null) return false;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return iproductLastPriceUpdate!.isAfter(thirtyDaysAgo);
  }

  // Validation methods
  bool get isValidBarcode => iproductBarcode.isNotEmpty;
  bool get isValidName => iproductName.isNotEmpty;
  bool get hasValidGlutenStatus => const [
        'gluten_free',
        'contains_gluten',
        'may_contain_gluten',
        'unknown',
      ].contains(iproductGlutenStatus);

  @override
  String toString() {
    return 'IProduct(id: $idIproduct, name: $iproductName, brand: $iproductBrand, price: $formattedPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IProduct &&
        other.idIproduct == idIproduct &&
        other.iproductBarcode == iproductBarcode;
  }

  @override
  int get hashCode => Object.hash(idIproduct, iproductBarcode);
}

// Helper functions for list operations
List<IProduct> parseIProducts(List<dynamic> jsonList) {
  return jsonList
      .map((json) => IProduct.fromJson(json as Map<String, dynamic>))
      .toList();
}

List<Map<String, dynamic>> iProductsToJson(List<IProduct> products) {
  return products.map((product) => product.toJson()).toList();
}

// Extension for list utilities
extension IProductListExtensions on List<IProduct> {
  List<IProduct> get glutenFreeProducts {
    return where((product) => product.isGlutenFree).toList();
  }

  List<IProduct> get productsWithGluten {
    return where((product) => product.containsGluten).toList();
  }

  List<IProduct> searchByName(String query) {
    if (query.isEmpty) return this;
    final lowerQuery = query.toLowerCase();
    return where((product) =>
        product.iproductName.toLowerCase().contains(lowerQuery) ||
        product.iproductBrand.toLowerCase().contains(lowerQuery)).toList();
  }

  List<IProduct> sortByPrice({bool ascending = true}) {
    return [...this]..sort((a, b) {
        final comparison =
            a.iproductEstimatedPriceDA.compareTo(b.iproductEstimatedPriceDA);
        return ascending ? comparison : -comparison;
      });
  }

  List<IProduct> sortByName({bool ascending = true}) {
    return [...this]..sort((a, b) {
        final comparison = a.iproductName.compareTo(b.iproductName);
        return ascending ? comparison : -comparison;
      });
  }
}
