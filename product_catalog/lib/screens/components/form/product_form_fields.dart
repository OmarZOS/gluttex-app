import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/iProduct.dart';
import 'package:gluttex_core/business/product_form_data.dart';
import 'package:event/assistant_change_notifier.dart';
import 'package:event/components/lib.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:event/views/pricing_config_view_model.dart';
import 'package:ui/components/category_picker.dart';
import 'package:ui/components/pricing_config_card.dart';
import 'package:ui/components/supplier/supplier_picker.dart';
import 'package:product_catalog/screens/components/form/form_controllers.dart';
import 'package:product_catalog/screens/components/form/pricing_state.dart';
import 'package:product_catalog/screens/components/smart_form.dart';

class ProductFormFields extends StatelessWidget {
  final ProductFormData formData;
  final FormControllers controllers;
  final GlobalKey<FormState> formKey;
  final bool isUpdate;

  const ProductFormFields({
    super.key,
    required this.formData,
    required this.controllers,
    required this.formKey,
    required this.isUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final assistantNotifier = context.watch<AssistantNotifier>();

    return Column(
      children: [
        // ... other fields (name, brand, barcode) ...

// Name Field
        _buildSmartField(
          context: context,
          fieldId: ProductAssistedFields.IPRODUCT_NAME,
          controller: controllers.name,
          label: localizations.productNameTxt,
          validator: (value) => value?.isEmpty == true
              ? localizations.pleaseInputProductNameMsg
              : null,
        ),

        const SizedBox(height: 16),

        // Brand Field
        _buildSmartField(
          context: context,
          fieldId: ProductAssistedFields.IPRODUCT_BRAND,
          controller: controllers.brand,
          label: localizations.productBrandTxt,
          validator: (value) => value?.isEmpty == true
              ? localizations.pleaseInputProductBrandMsg
              : null,
        ),

        const SizedBox(height: 16),

        // Barcode Field with scanner

        _buildBarcodeField(context, localizations),

        const SizedBox(height: 16),

        // Price Field
        // Price Field with AI Assistant
        _buildPriceFieldWithAssistant(
            context, assistantNotifier, localizations),

        const SizedBox(height: 16),

        // Quantity Field
        _buildSmartField(
          context: context,
          fieldId: ProductAssistedFields.QUANTITY,
          controller: controllers.quantity,
          label: localizations.productQuantityText,
          keyboardType: TextInputType.number,
          validator: _validateQuantity,
        ),

        const SizedBox(height: 16),

        // Description Field
        _buildSmartField(
          context: context,
          fieldId: ProductAssistedFields.DESCRIPTION,
          controller: controllers.description,
          label: localizations.productDescriptionText,
          maxLines: 3,
          validator: _validateDescription,
        ),

        const SizedBox(height: 24),

        // Category Picker
        _buildCategoryPicker(context),

        const SizedBox(height: 24),

        // Supplier Picker
        _buildSupplierPicker(context),
      ],
    );
  }

  Widget _buildPriceFieldWithAssistant(
    BuildContext context,
    AssistantNotifier assistantNotifier,
    AppLocalizations localizations,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final priceField = assistantNotifier
        .getFieldData(ProductAssistedFields.IPRODUCT_ESTIMATED_PRICE_DA);
    final hasAIPrice = priceField?.value != null && !priceField!.isEdited;
    final aiPrice =
        hasAIPrice ? double.tryParse(priceField!.value.toString()) : null;

    return Consumer<PricingState>(
      builder: (context, pricingState, child) {
        // ✅ Create a local controller that only updates on significant changes
        return _PricingCardWrapper(
          pricingState: pricingState,
          aiPrice: aiPrice,
          hasAIPrice: hasAIPrice,
          childBuilder: (localValues) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Smart Price Field
              _buildSmartField(
                context: context,
                fieldId: ProductAssistedFields.IPRODUCT_ESTIMATED_PRICE_DA,
                controller: controllers.price,
                label: localizations.productPriceTxt,
                keyboardType: TextInputType.number,
                validator: _validatePrice,
                suffixIcon: hasAIPrice
                    ? Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      )
                    : null,
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 0.0;
                  pricingState.updateBasePrice(price);
                  formData.price = price;
                },
              ),

              const SizedBox(height: 16),

              // AI Price Suggestion Header
              if (hasAIPrice && aiPrice != null)
                Column(
                  children: [
                    _buildAIPriceSuggestionHeader(
                        context, aiPrice!, pricingState, localizations),
                    const SizedBox(height: 12),
                  ],
                ),

              // Pricing Configuration Card with local values
              PricingConfigCard(
                basePrice: localValues.basePrice,
                taxPercentage: localValues.taxPercentage,
                profitMargin: localValues.profitMargin,
                finalPrice: localValues.finalPrice,
                mode: localValues.mode,
                onBasePriceChanged: (price) {
                  pricingState.updateBasePrice(price);
                  formData.price = price;
                },
                onTaxPercentageChanged: (tax) {
                  pricingState.updateTaxPercentage(tax);
                },
                onProfitMarginChanged: (margin) {
                  pricingState.updateProfitMargin(margin);
                },
                onFinalPriceChanged: (price) {
                  pricingState.updateFinalPrice(price);
                  formData.price = price;
                },
                onModeChanged: (mode) {
                  pricingState.updateMode(mode);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIPriceSuggestionHeader(
    BuildContext context,
    double aiPrice,
    PricingState pricingState,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentPrice = pricingState.basePrice;
    final priceDifference = (currentPrice - aiPrice).abs();
    final isPriceAccepted = priceDifference < 0.01;
    final isHigher = currentPrice > aiPrice;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Suggested Price',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'DZD${aiPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isPriceAccepted)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isHigher
                          ? 'Your price is DZD${priceDifference.toStringAsFixed(2)} higher'
                          : 'Your price is DZD${priceDifference.toStringAsFixed(2)} lower',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isHigher ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Accept/Reject Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPriceAccepted
                  ? colorScheme.primary.withOpacity(0.2)
                  : colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isPriceAccepted ? Icons.check_circle : Icons.price_change,
                size: 20,
                color: isPriceAccepted
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                final newPrice = isPriceAccepted ? 0.0 : aiPrice;
                pricingState.updateBasePrice(newPrice);
                controllers.price.text = newPrice.toStringAsFixed(2);
                formData.price = newPrice;
              },
              padding: EdgeInsets.zero,
              splashRadius: 16,
              tooltip: isPriceAccepted ? 'Reset to AI price' : 'Use AI price',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPricingCard(
    BuildContext context,
    double aiSuggestedPrice,
    PricingState pricingState,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Suggestion Header
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI Suggested Price: DZD${aiSuggestedPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildAcceptPriceButton(context, aiSuggestedPrice, pricingState),
            ],
          ),

          const SizedBox(height: 16),

          // Pricing Configuration Card
          PricingConfigCard(
            basePrice: pricingState.basePrice,
            taxPercentage: pricingState.taxPercentage,
            profitMargin: pricingState.profitMargin,
            finalPrice: pricingState.finalPrice,
            mode: pricingState.mode,
            onBasePriceChanged: (price) {
              pricingState.updateBasePrice(price);
              controllers.price.text = price.toStringAsFixed(2);
            },
            onTaxPercentageChanged: pricingState.updateTaxPercentage,
            onProfitMarginChanged: pricingState.updateProfitMargin,
            onFinalPriceChanged: (price) {
              pricingState.updateFinalPrice(price);
              controllers.price.text = price.toStringAsFixed(2);
            },
            onModeChanged: pricingState.updateMode,
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptPriceButton(
    BuildContext context,
    double aiPrice,
    PricingState pricingState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentPrice = double.tryParse(controllers.price.text) ?? 0.0;
    final isPriceAccepted = (currentPrice - aiPrice).abs() < 0.01;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isPriceAccepted
            ? colorScheme.primary.withOpacity(0.2)
            : colorScheme.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isPriceAccepted ? Icons.check_circle : Icons.price_change,
          size: 18,
          color: isPriceAccepted
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          final newPrice = isPriceAccepted ? 0.0 : aiPrice;
          controllers.price.text = newPrice.toStringAsFixed(2);
          pricingState.updateBasePrice(newPrice);
        },
        padding: EdgeInsets.zero,
        splashRadius: 16,
      ),
    );
  }

  Widget _buildSmartField({
    required BuildContext context,
    required String fieldId,
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Consumer<AssistantNotifier>(
      builder: (context, assistantNotifier, child) {
        return SmartFormField(
          fieldId: fieldId,
          controller: controller,
          labelText: label,
          validator: validator!,
          onSaved: (value) => _onFieldSaved(fieldId, value),
          keyboardType: keyboardType,
          suffixIcon: suffixIcon,
          maxLines: maxLines,
          onChanged: onChanged,
        );
      },
    );
  }

  void _onFieldSaved(String fieldId, String? value) {
    switch (fieldId) {
      case ProductAssistedFields.IPRODUCT_NAME:
        formData.productName = value;
        break;
      case ProductAssistedFields.IPRODUCT_BRAND:
        formData.productBrand = value;
        break;
      case ProductAssistedFields.IPRODUCT_BARCODE:
        formData.productBarcode = value;
        break;
      case ProductAssistedFields.IPRODUCT_ESTIMATED_PRICE_DA:
        formData.price = double.tryParse(value ?? '0.0');
        break;
      case ProductAssistedFields.QUANTITY:
        formData.quantity = int.tryParse(value ?? '0');
        break;
      case ProductAssistedFields.DESCRIPTION:
        formData.productDescription = value;
        break;
    }
  }

  String? _validatePrice(String? value) {
    if (value?.isEmpty == true) return 'Please enter price';
    if (double.tryParse(value ?? '') == null)
      return 'Please enter a valid number';
    if (double.tryParse(value ?? '')! >= 1000000) return 'Price too high';
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value?.isEmpty == true) return 'Please enter quantity';
    if (int.tryParse(value ?? '') == null) return 'Please enter a valid number';
    return null;
  }

  String? _validateDescription(String? value) {
    if (value?.isEmpty == true) return 'Please enter description';
    if (value!.length >= 300)
      return 'Description too long (max 300 characters)';
    return null;
  }

  Widget _buildCategoryPicker(BuildContext context) {
    final categories = context.read<ProductNotifier>().categories;
    return CategoryPicker(
      category_id: formData.categoryId ?? 1,
      categories: categories,
      onCategoryChanged: (id) {
        formData.typeId = id;
        formData.categoryId = id;
      },
      pathFunction: (id) => 'assets/icons/$id.svg',
      package: "product_catalog",
    );
  }

  Widget _buildSupplierPicker(BuildContext context) {
    final userNotifier = context.watch<AppUserNotifier>();
    final supplierNotifier = context.watch<SupplierChangeNotifier>();
    final personnelNotifier = context.watch<PersonnelNotifier>();

    final currentUserId = userNotifier.appUser?.idAppUser;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    // Ensure personnel rules are loaded if not already
    if (personnelNotifier.personnel.isEmpty &&
        !personnelNotifier.isLoading &&
        personnelNotifier.hasMore) {
      // Load the rules in the background
      WidgetsBinding.instance.addPostFrameCallback((_) {
        personnelNotifier.loadPersonnel(
          userId: currentUserId,
          reset: true,
          includePending: false,
        );
      });
    }

    // Get suppliers owned by the user
    final userOwnedSuppliers = supplierNotifier.suppliers.where((supplier) {
      return supplier.productProviderOwnerId == currentUserId;
    }).toList();

    // Get managed suppliers from personnel (if user has access to other suppliers)
    final managedSupplierIds =
        personnelNotifier.getAccessibleSupplierIds(currentUserId);
    final managedSuppliers = supplierNotifier.suppliers.where((supplier) {
      return managedSupplierIds.contains(supplier.idProductProvider);
    }).toList();

    // Combine and remove duplicates
    final allAccessibleSuppliers = {
      ...userOwnedSuppliers,
      ...managedSuppliers,
    }.toList();

    // Show loading indicator while personnel rules are being loaded
    if (personnelNotifier.isLoading && allAccessibleSuppliers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // If no suppliers available, show message and option to create
    if (allAccessibleSuppliers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No suppliers available',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.providerCreate);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Supplier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Supplier',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            if (personnelNotifier.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SupplierPicker(
          onSupplierChanged: (selectedSupplier) {
            formData.selectedProviderId = selectedSupplier.idProductProvider;
            formData.selectedProviderId = selectedSupplier.idProductProvider;
          },
          suppliers: allAccessibleSuppliers,
          initialSelection: allAccessibleSuppliers.isNotEmpty
              ? allAccessibleSuppliers.firstWhere(
                  (s) => s.idProductProvider == formData.selectedProviderId,
                  orElse: () => allAccessibleSuppliers.first,
                )
              : null,
        ),
      ],
    );
  }

  // Update the _buildSmartField method for barcode to include scanning
  Widget _buildBarcodeField(
      BuildContext context, AppLocalizations localizations) {
    final assistantNotifier = context.watch<AssistantNotifier>();

    return _buildSmartField(
      context: context,
      fieldId: ProductAssistedFields.IPRODUCT_BARCODE,
      controller: controllers.barcode,
      label: localizations.productBarcodeTxt,
      validator: (value) => value?.isEmpty == true
          ? localizations.pleaseInputProductBarcodeMsg
          : null,
      suffixIcon: IconButton(
        icon: Icon(CupertinoIcons.barcode_viewfinder,
            color: Theme.of(context).colorScheme.primary),
        onPressed: assistantNotifier.isLoading
            ? null
            : () => _handleBarcodeScanning(context),
      ),
    );
  }

// Add this method to handle barcode scanning from the form field
  Future<void> _handleBarcodeScanning(BuildContext context) async {
    final String? scannedCode = await Navigator.pushNamed(
      context,
      AppRoutes.productScanPage,
    ) as String?;

    if (scannedCode != null && scannedCode.isNotEmpty) {
      final assistantNotifier = context.read<AssistantNotifier>();

      // Update barcode field immediately with user input source
      assistantNotifier.setFieldData(
        fieldId: ProductAssistedFields.IPRODUCT_BARCODE,
        value: scannedCode,
        source: DataSource.userInput,
      );

      // Update form data and controller
      formData.productBarcode = scannedCode;
      controllers.barcode.text = scannedCode;

      // Then fetch product data
      await assistantNotifier.fetchProductByBarcode(scannedCode);

      // Auto-sync form with the fetched data
      _syncFormWithAiData(context);
    }
  }

  void _syncFormWithAiData(BuildContext context) {
    final assistantNotifier = context.read<AssistantNotifier>();
    final IProduct? currentProduct = assistantNotifier.product;

    if (currentProduct == null || !context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      // Get field data
      final nameField =
          assistantNotifier.getFieldData(ProductAssistedFields.IPRODUCT_NAME);
      final brandField =
          assistantNotifier.getFieldData(ProductAssistedFields.IPRODUCT_BRAND);
      final priceField = assistantNotifier
          .getFieldData(ProductAssistedFields.IPRODUCT_ESTIMATED_PRICE_DA);

      // Update only non-edited fields
      if (nameField != null && !nameField.isEdited) {
        controllers.name.text = nameField.value?.toString() ?? '';
        formData.productName = nameField.value?.toString();
      }

      if (brandField != null && !brandField.isEdited) {
        controllers.brand.text = brandField.value?.toString() ?? '';
        formData.productBrand = brandField.value?.toString();
      }

      if (priceField != null && !priceField.isEdited) {
        controllers.price.text = priceField.value?.toString() ?? '';
        formData.price = double.tryParse(priceField.value?.toString() ?? '0.0');
      }

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product data loaded from barcode'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    });
  }
}

// Helper widget to manage local state
class _PricingCardWrapper extends StatefulWidget {
  final PricingState pricingState;
  final double? aiPrice;
  final bool hasAIPrice;
  final Widget Function(PricingValues localValues) childBuilder;

  const _PricingCardWrapper({
    required this.pricingState,
    required this.aiPrice,
    required this.hasAIPrice,
    required this.childBuilder,
  });

  @override
  State<_PricingCardWrapper> createState() => __PricingCardWrapperState();
}

class __PricingCardWrapperState extends State<_PricingCardWrapper> {
  late PricingValues _localValues;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _localValues = PricingValues.fromPricingState(widget.pricingState);

    // Initialize with AI price if available
    if (widget.hasAIPrice && widget.aiPrice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.pricingState.updateBasePrice(widget.aiPrice!);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supplierNotifier = context.read<SupplierChangeNotifier>();
      if (supplierNotifier.suppliers.isEmpty && !supplierNotifier.isLoading) {
        final userNotifier = context.read<AppUserNotifier>();
        supplierNotifier.fetchSuppliers(
          reset: true,
          ownerId: userNotifier.appUser?.idAppUser,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant _PricingCardWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update local values if the user isn't actively using the card
    // This prevents resetting while typing
    if (_shouldUpdateLocalValues()) {
      _localValues = PricingValues.fromPricingState(widget.pricingState);
    }
  }

  bool _shouldUpdateLocalValues() {
    // Add logic here if you want to track when user is editing
    // For now, update on significant changes only
    final currentState = widget.pricingState;
    return _localValues.basePrice != currentState.basePrice ||
        _localValues.taxPercentage != currentState.taxPercentage ||
        _localValues.mode != currentState.mode;
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(_localValues);
  }
}

// Simple data class for local values
class PricingValues {
  final double basePrice;
  final double taxPercentage;
  final double profitMargin;
  final double finalPrice;
  final PricingMode mode;

  PricingValues({
    required this.basePrice,
    required this.taxPercentage,
    required this.profitMargin,
    required this.finalPrice,
    required this.mode,
  });

  factory PricingValues.fromPricingState(PricingState state) {
    return PricingValues(
      basePrice: state.basePrice,
      taxPercentage: state.taxPercentage,
      profitMargin: state.profitMargin,
      finalPrice: state.finalPrice,
      mode: state.mode,
    );
  }
}
