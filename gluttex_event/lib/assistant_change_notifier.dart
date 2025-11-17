import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/iProduct.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class AssistantNotifier extends ChangeNotifier {
  final StorageService _storageService = GluttexLocator.get<StorageService>();

  // Core data storage
  final Map<int, IProduct> _iproducts = {};
  final Map<String, FieldData> _fieldData = {};
  final Map<String, Set<String>> _productFields = {}; // productId -> fieldIds

  // State management
  bool _isLoading = false;
  String? _lastError;
  String? _lastOperation;
  DateTime? _lastUpdated;

  // ======= PUBLIC GETTERS =======
  List<IProduct> get iproducts => _iproducts.values.toList();
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  String? get lastOperation => _lastOperation;
  DateTime? get lastUpdated => _lastUpdated;

  Map<String, FieldData> get fieldData => Map.unmodifiable(_fieldData);

  // ======= FIELD DATA MANAGEMENT =======

  /// Get field data for a specific field
  FieldData? getFieldData(String fieldId) => _fieldData[fieldId];

  /// Check if a field has been edited by user
  bool isFieldEdited(String fieldId) => _fieldData[fieldId]?.isEdited ?? false;

  /// Get the source of field data
  DataSource getFieldSource(String fieldId) =>
      _fieldData[fieldId]?.source ?? DataSource.userInput;

  /// Set field data with automatic source tracking
  void setFieldData({
    required String fieldId,
    required dynamic value,
    required DataSource source,
    String? productId,
    double confidence = 1.0,
    String? operationId,
  }) {
    final fieldKey = _generateFieldKey(fieldId, productId);

    _fieldData[fieldKey] = FieldData(
      value: value,
      source: source,
      confidence: confidence,
      isEdited: false,
      lastUpdated: DateTime.now(),
      operationId: operationId,
    );

    // Track fields per product
    if (productId != null) {
      _productFields.putIfAbsent(productId, () => {}).add(fieldKey);
    }

    _lastUpdated = DateTime.now();
    _lastOperation = 'field_data_set';
    notifyListeners();

    log('📝 Field data set: $fieldKey | Source: ${source.name} | Confidence: $confidence');
  }

  /// Mark field as edited by user - removes source badge
  void markFieldAsEdited(String fieldId, {String? productId}) {
    final fieldKey = _generateFieldKey(fieldId, productId);
    final existingData = _fieldData[fieldKey];

    if (existingData != null && !existingData.isEdited) {
      _fieldData[fieldKey] = existingData.copyWith(
        isEdited: true,
        lastUpdated: DateTime.now(),
      );

      _lastUpdated = DateTime.now();
      _lastOperation = 'field_edited';
      notifyListeners();

      log('✏️ Field marked as edited: $fieldKey');
    }
  }

  /// Bulk update multiple fields from AI/database source
  void setMultipleFields({
    required Map<String, dynamic> fieldValues,
    required DataSource source,
    String? productId,
    double confidence = 1.0,
    String operationId = 'bulk_update',
  }) {
    for (final entry in fieldValues.entries) {
      setFieldData(
        fieldId: entry.key,
        value: entry.value,
        source: source,
        productId: productId,
        confidence: confidence,
        operationId: operationId,
      );
    }
  }

  /// Clear all field data for a specific product
  void clearProductFields(String productId) {
    final fieldsToRemove = _productFields[productId] ?? {};
    for (final fieldKey in fieldsToRemove) {
      _fieldData.remove(fieldKey);
    }
    _productFields.remove(productId);
    notifyListeners();
  }

  /// Get all fields for a product that haven't been edited
  Map<String, FieldData> getUneditedProductFields(String productId) {
    final fields = _productFields[productId] ?? {};
    return Map.fromEntries(_fieldData.entries
        .where((entry) => fields.contains(entry.key) && !entry.value.isEdited));
  }

  /// Get field data confidence score for a product
  double getProductConfidenceScore(String productId) {
    final fields = _productFields[productId] ?? {};
    if (fields.isEmpty) return 0.0;

    final totalConfidence = fields
        .map((fieldKey) => _fieldData[fieldKey]?.confidence ?? 0.0)
        .reduce((a, b) => a + b);

    return totalConfidence / fields.length;
  }

  // ======= PRODUCT OPERATIONS =======

  /// Fetch by barcode with intelligent caching and field tracking
  Future<IProduct?> getProductByBarcode(
    String barcode, {
    String operationId = 'barcode_lookup',
    bool forceRefresh = false,
  }) async {
    if (barcode.trim().isEmpty) return null;

    // Try local cache first (unless force refresh)
    if (!forceRefresh) {
      final cached = _findProductByBarcode(barcode);
      if (cached != null) {
        _lastOperation = 'cache_hit';
        log('🎯 Cache hit for barcode: $barcode');
        return cached;
      }
    }

    _setLoading(true, operation: 'barcode_fetch');
    try {
      final result = await _storageService.get(
        GluttexConstants.getProductSearchByBarcodeEndpoint,
        barcode,
      );

      if (result != null && result is Map<String, dynamic>) {
        final product = IProduct.fromJson(result);
        await _cacheProduct(product, operationId: operationId);

        // Auto-populate field data from database
        _populateFieldDataFromProduct(product,
            source: DataSource.databaseFetched);

        _setLastOperation(
            'barcode_success', 'Found product: ${product.iproductName}');
        return product;
      } else {
        _setLastOperation(
            'barcode_not_found', 'No product found for barcode: $barcode');
        return null;
      }
    } on GluttexException catch (e) {
      _setError('Database lookup failed: ${e.message}',
          operation: 'barcode_error');
      return null;
    } catch (e) {
      _setError('Unexpected error: $e', operation: 'barcode_error');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// AI product recognition from image with field tracking
  Future<IProduct?> getProductFromImage(
    dynamic imageData, {
    String operationId = 'image_recognition',
  }) async {
    if (imageData == null || (imageData is List && imageData.isEmpty)) {
      _setError('Invalid image data', operation: 'image_error');
      return null;
    }

    _setLoading(true, operation: 'image_analysis');
    try {
      final result = await _storageService.insertBinary(
        GluttexConstants.getProductSearchByImageEndpoint,
        imageData,
      );

      if (result != null && result is List) {
        final products = result
            .whereType<Map<String, dynamic>>()
            .map((data) => IProduct.fromJson(data))
            .toList();

        if (products.isNotEmpty) {
          final product = products.first; // Take the best match
          await _cacheProduct(product, operationId: operationId);

          // Auto-populate field data from AI analysis
          _populateFieldDataFromProduct(
            product,
            source: DataSource.aiGenerated,
            confidence: 0.8, // AI typically has lower confidence than database
          );

          _setLastOperation(
              'image_success', 'AI identified: ${product.iproductName}');
          return product;
        }
      }

      _setLastOperation('image_no_match', 'AI could not identify product');
      return null;
    } on GluttexException catch (e) {
      _setError('AI recognition failed: ${e.message}',
          operation: 'image_error');
      return null;
    } catch (e) {
      _setError('Image processing error: $e', operation: 'image_error');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Manual product creation with field tracking
  void createManualProduct(IProduct product,
      {String operationId = 'manual_create'}) {
    _cacheProduct(product, operationId: operationId);
    _populateFieldDataFromProduct(product, source: DataSource.userInput);
    _setLastOperation(
        'manual_created', 'Manual product: ${product.iproductName}');
  }

  // ======= PRIVATE HELPERS =======

  String _generateFieldKey(String fieldId, String? productId) {
    return productId != null ? '${productId}_$fieldId' : fieldId;
  }

  IProduct? _findProductByBarcode(String barcode) {
    try {
      return _iproducts.values.firstWhere(
        (p) => p.iproductBarcode == barcode,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheProduct(IProduct product,
      {required String operationId}) async {
    _iproducts[product.idIproduct ?? 1] = product;

    // Optional: Persist to local storage
    // await _storageService.saveIProduct(product);

    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  void _populateFieldDataFromProduct(
    IProduct product, {
    required DataSource source,
    double confidence = 1.0,
  }) {
    final fieldMap = <String, dynamic>{
      'name': product.iproductName,
      'brand': product.iproductBrand,
      'barcode': product.iproductBarcode,
      'price': product.formattedPrice,
      'gluten_status': product.iproductGlutenStatus,
      // 'description': product.,
    };

    setMultipleFields(
      fieldValues: fieldMap,
      source: source,
      productId: product.idIproduct.toString(),
      confidence: confidence,
      operationId: 'product_populate',
    );
  }

  void _setLoading(bool value, {String? operation}) {
    _isLoading = value;
    if (operation != null) {
      _lastOperation = 'loading_$operation';
    }
    if (value) _lastError = null;
    notifyListeners();
  }

  void _setError(String message, {String? operation}) {
    _lastError = message;
    _lastOperation = operation ?? 'error';
    log('❌ Assistant Error: $message');
    notifyListeners();
  }

  void _setLastOperation(String operation, String details) {
    _lastOperation = operation;
    log('✅ Assistant: $details');
  }

  // ======= DEBUG & UTILITY METHODS =======

  /// Debug method to print current state
  void debugPrintState() {
    log('=== AssistantNotifier Debug ===');
    log('Products: ${_iproducts.length}');
    log('Fields: ${_fieldData.length}');
    log('Loading: $_isLoading');
    log('Last Error: $_lastError');
    log('Last Operation: $_lastOperation');
    log('Last Updated: $_lastUpdated');

    _fieldData.forEach((key, value) {
      log('Field $key: ${value.value} | Source: ${value.source.name} | Edited: ${value.isEdited}');
    });
  }

  /// Clear all state
  void clearAll() {
    _iproducts.clear();
    _fieldData.clear();
    _productFields.clear();
    _isLoading = false;
    _lastError = null;
    _lastOperation = null;
    _lastUpdated = null;
    notifyListeners();
  }
}

// ======= SUPPORTING CLASSES =======

class FieldData {
  final dynamic value;
  final DataSource source;
  final double confidence; // 0.0 to 1.0
  final bool isEdited;
  final DateTime lastUpdated;
  final String? operationId;

  const FieldData({
    required this.value,
    required this.source,
    this.confidence = 1.0,
    this.isEdited = false,
    required this.lastUpdated,
    this.operationId,
  });

  FieldData copyWith({
    dynamic value,
    DataSource? source,
    double? confidence,
    bool? isEdited,
    DateTime? lastUpdated,
    String? operationId,
  }) {
    return FieldData(
      value: value ?? this.value,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      isEdited: isEdited ?? this.isEdited,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      operationId: operationId ?? this.operationId,
    );
  }

  @override
  String toString() {
    return 'FieldData(value: $value, source: $source, confidence: $confidence, edited: $isEdited)';
  }
}

enum DataSource {
  aiGenerated('AI Generated', Icons.auto_awesome, Colors.green),
  databaseFetched('Database Fetched', Icons.storage, Colors.blue),
  userInput('User Input', Icons.edit, Colors.orange);

  final String displayName;
  final IconData icon;
  final Color color;

  const DataSource(this.displayName, this.icon, this.color);
}

// Extension for easy color scheme integration
extension DataSourceTheme on DataSource {
  Color getColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (this) {
      DataSource.aiGenerated => scheme.tertiary,
      DataSource.databaseFetched => scheme.primary,
      DataSource.userInput => scheme.secondary,
    };
  }

  Color getContainerColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (this) {
      DataSource.aiGenerated => scheme.tertiaryContainer,
      DataSource.databaseFetched => scheme.primaryContainer,
      DataSource.userInput => scheme.secondaryContainer,
    };
  }
}
