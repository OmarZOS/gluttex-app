import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_constants/gluttex_response_codes.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/iProduct.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/assistant_change_notifier.dart';
import 'package:gluttex_event/components/lib.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:gluttex_ui/components/supplier/supplier_picker.dart';
import 'package:gluttex_ui/components/ImagePickerSection.dart';
import 'package:gluttex_ui/components/category_picker.dart';
import 'package:locator/locator.dart';
import 'package:medicom_catalog/screens/components/smart_form.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({Key? key}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Product data fields
  String? _productName;
  String? _productBrand;
  String? _productBarcode;
  GluttexImage? _productImage;
  File? _productImageFile;
  int? _productTypeId;
  double? _productPrice;
  int? _productQuantity;
  String? _productQuantifier;
  int? _productOwnerId;
  int? _productProviderId;
  int? _productCategoryId;
  int? _idProduct;
  int? _idProductImage;
  String? _imageUrl;
  bool _updatePage = false;
  String? _productDescription;

  // Controllers
  late TextEditingController _barcodeController;
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;

  // State variables
  bool _initialized = false;
  int _selectedProviderId = 0;
  late Supplier _initialSupplier;
  late AppUserNotifier _userNotifier;
  late SupplierChangeNotifier _supplierNotifier;
  String? _currentProductId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeProviders();
    _currentProductId = 'product_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _initializeControllers() {
    _barcodeController = TextEditingController();
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void _initializeProviders() {
    _userNotifier = Provider.of<AppUserNotifier>(context, listen: false);
    _supplierNotifier =
        Provider.of<SupplierChangeNotifier>(context, listen: false);

    // Set initial supplier
    final supplierList = _supplierNotifier.suppliers
        .where((s) =>
            s?.productProviderOwnerId == _userNotifier.appUser?.id_app_user)
        .whereType<Supplier>()
        .toList();

    _initialSupplier =
        supplierList.isNotEmpty ? supplierList.first : Supplier.empty();
    _selectedProviderId = _initialSupplier.idProductProvider;
    _productOwnerId = _userNotifier.appUser?.id_app_user ?? 1;
  }

// Add this method to clear field data when needed
  void _clearAssistantData() {
    final assistantNotifier = context.read<AssistantNotifier>();
    assistantNotifier.clearFieldData();
    assistantNotifier.clearProduct();
  }

// Update your dispose method
  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();

    final assistantNotifier = context.read<AssistantNotifier>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      assistantNotifier.clearAll();
    });
    // Only clear assistant data if this is a new product form
    // if (!_updatePage) {}

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeFromArguments();
      _initialized = true;
    }
  }

  void _initializeFromArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Product? product = args?['product'];

    // Set default values
    _productQuantifier = GluttexConstants.productUnits.first;
    _productCategoryId = 1;

    if (product != null) {
      _updatePage = true;
      _populateFormFromProduct(product);
    }
  }

  void _populateFormFromProduct(Product product) {
    _productName = product.product_name;
    // assistantNotifier.markFieldAsEdited.()
    _productBrand = product.product_brand;
    _productBarcode = product.product_barcode;
    _imageUrl = product.product_image_url ?? '';
    _productTypeId = product.product_category_id ?? 1;
    _productPrice = product.product_price;
    _productQuantity = product.product_quantity;
    _productQuantifier =
        product.product_quantifier ?? GluttexConstants.productUnits.first;
    _productOwnerId =
        product.product_owner_id ?? _userNotifier.appUser?.id_app_user ?? 1;
    _productDescription = product.product_description;
    _productProviderId = product.product_provider_id;
    _productCategoryId = product.product_category_id;
    _idProduct = product.id_product;
    _idProductImage = product.id_product_image;

    // Update controllers
    _nameController.text = _productName ?? '';
    _brandController.text = _productBrand ?? '';
    _barcodeController.text = _productBarcode ?? '';
    _priceController.text = _productPrice?.toString() ?? '';
    _quantityController.text = _productQuantity?.toString() ?? '';
    _descriptionController.text = _productDescription ?? '';
  }

  String _getUnitText(String unit, AppLocalizations loc) {
    final unitMap = {
      'g': loc.quantifier_g,
      'kg': loc.quantifier_kg,
      'mg': loc.quantifier_mg,
      'L': loc.quantifier_L,
      'mL': loc.quantifier_mL,
      'pc': loc.quantifier_pc,
      'pkg': loc.quantifier_pkg,
      'box': loc.quantifier_box,
      'bag': loc.quantifier_bag,
      'slice': loc.quantifier_slice,
      'cup': loc.quantifier_cup,
    };
    return unitMap[unit] ?? loc.quantifier_pc;
  }

  void _onCategoryChanged(int identifier) {
    setState(() {
      _productTypeId = identifier;
      _productCategoryId = identifier;
    });
  }

  // ======= PREMIUM AI ASSISTANCE =======
  Future<void> _showAiAssistanceOptions() async {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final option = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.aiAssistantTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                          Text(
                            loc.aiAssistantSubtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Options
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildAiOption(
                      icon: CupertinoIcons.barcode_viewfinder,
                      title: loc.scanBarcode,
                      subtitle: loc.automaticallyFillDetailsFromBarcode,
                      color: colorScheme.primary,
                      onTap: () => Navigator.pop(context, 1),
                    ),
                    const SizedBox(height: 12),
                    _buildAiOption(
                      icon: Icons.camera_alt,
                      title: loc.takeProductPhoto,
                      subtitle: loc.aiWillAnalyseImage,
                      color: colorScheme.secondary,
                      onTap: () => Navigator.pop(context, 3),
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(loc.cancelTxt),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (option != null) {
      await _handleAiAssistanceOption(option);
    }
  }

// Update your AI assistance button to show confidence
  Widget _buildAiAssistanceButton(AppLocalizations loc) {
    return Consumer<AssistantNotifier>(
      builder: (context, assistantNotifier, child) {
        final isLoading = assistantNotifier.isLoading;
        final hasAssistedData = assistantNotifier.hasAssistedData;
        final confidence = assistantNotifier.getProductConfidenceScore();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.onPrimary, size: 20),
              ),
              title: Text(
                loc.aiAssistantTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.aiAssistantSubtitle,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  if (hasAssistedData && confidence > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${(confidence * 100).toStringAsFixed(0)}% fields filled automatically',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary),
                    ),
              onTap: isLoading ? null : _showAiAssistanceOptions,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward, color: color, size: 16),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Future<void> _handleAiAssistanceOption(int option) async {
    try {
      if (option == 1) {
        await _handleBarcodeScanning();
      } else if (option == 3) {
        await _handleProductPhotoCapture();
      }
    } catch (e) {
      _showErrorSnackBar('AI assistance failed. Please try again.');
    }
  }

  // Handle barcode scanning - UPDATED
  Future<void> _handleBarcodeScanning() async {
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

      setState(() {
        _productBarcode = scannedCode;
        _barcodeController.text = scannedCode;
      });

      // Then fetch product data
      await assistantNotifier.fetchProductByBarcode(scannedCode);

      // Auto-sync form with the fetched data
      _syncFormWithAssistantData();
    }
  }

  // Handle image capture - UPDATED
  Future<void> _handleProductPhotoCapture() async {
    final File? capturedImage = await Navigator.pushNamed(
      context,
      AppRoutes.productCapturePage,
    ) as File?;

    if (capturedImage != null) {
      final assistantNotifier = context.read<AssistantNotifier>();

      // Handle image setup
      GluttexImage gluttexImage = GluttexLocator.get<GluttexImage>();
      gluttexImage.setupImage(
        filepath: capturedImage.path,
        filename: path.basename(capturedImage.path),
        entityType: "product",
        ownerId: "$_productOwnerId",
        entityId: '$_idProduct',
      );

      setState(() {
        _productImageFile = capturedImage;
        _productImage = gluttexImage;
      });

      // Start AI recognition
      await assistantNotifier.recognizeProductFromImage(capturedImage);

      // Auto-sync form with the recognized data
      _syncFormWithAssistantData();
    }
  }

// Update your _syncFormWithAssistantData method:
  void _syncFormWithAssistantData() {
    final assistantNotifier = context.read<AssistantNotifier>();
    final IProduct? currentProduct = assistantNotifier.product;

    if (currentProduct == null || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Get all field data
      final nameField =
          assistantNotifier.getFieldData(ProductAssistedFields.IPRODUCT_NAME);
      final brandField =
          assistantNotifier.getFieldData(ProductAssistedFields.IPRODUCT_BRAND);
      final barcodeField = assistantNotifier
          .getFieldData(ProductAssistedFields.IPRODUCT_BARCODE);
      final priceField = assistantNotifier
          .getFieldData(ProductAssistedFields.IPRODUCT_ESTIMATED_PRICE_DA);
      final quantityField =
          assistantNotifier.getFieldData(ProductAssistedFields.QUANTITY);
      final quantifierField =
          assistantNotifier.getFieldData(ProductAssistedFields.QUANTIFIER);

      setState(() {
        // Only update fields that haven't been edited by user
        if (nameField != null && !nameField.isEdited) {
          _nameController.text = nameField.value?.toString() ?? '';
          _productName = nameField.value?.toString();
        }

        if (brandField != null && !brandField.isEdited) {
          _brandController.text = brandField.value?.toString() ?? '';
          _productBrand = brandField.value?.toString();
        }

        if (barcodeField != null && !barcodeField.isEdited) {
          _barcodeController.text = barcodeField.value?.toString() ?? '';
          _productBarcode = barcodeField.value?.toString();
        }

        if (priceField != null && !priceField.isEdited) {
          _priceController.text = priceField.value?.toString() ?? '';
          _productPrice =
              double.tryParse(priceField.value?.toString() ?? '0.0');
        }

        // Handle quantity field
        if (quantityField != null && !quantityField.isEdited) {
          _quantityController.text = quantityField.value?.toString() ?? '1';
          _productQuantity =
              int.tryParse(quantityField.value?.toString() ?? '1');
        }

        // Handle quantifier field
        if (quantifierField != null && !quantifierField.isEdited) {
          final quantifierValue = quantifierField.value?.toString() ?? 'pc';
          _productQuantifier = quantifierValue;
          // Note: For dropdown, we need to ensure the value is in the dropdown items
          if (GluttexConstants.productUnits.contains(quantifierValue)) {
            _productQuantifier = quantifierValue;
          }
        }

        // Always update description if available
        // _descriptionController.text = currentProduct.iproductDescription ?? '';
        // _productDescription = currentProduct.iproductDescription;
      });

      _showSuccessSnackBar('Product data loaded successfully!');

      // Show confidence score if available
      final confidence = assistantNotifier.getProductConfidenceScore();
      if (confidence > 0) {
        debugPrint(
            "🎯 Overall confidence: ${(confidence * 100).toStringAsFixed(0)}%");
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle,
                color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.onError),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ======= PREMIUM SMART FORM FIELDS =======
  Widget _buildSmartFormField({
    required String fieldId,
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    int? maxLines,
  }) {
    return Consumer<AssistantNotifier>(
      builder: (context, assistantNotifier, child) {
        return SmartFormField(
          fieldId: fieldId,
          controller: controller,
          labelText: labelText,
          validator: validator,
          onSaved: onSaved,
          keyboardType: keyboardType,
          suffixIcon: suffixIcon,
          maxLines: maxLines,
        );
      },
    );
  }

  Widget _buildSmartDropdownField({
    required String fieldId,
    required String value,
    required String labelText,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
  }) {
    return Consumer<AssistantNotifier>(
      builder: (context, assistantNotifier, child) {
        return SmartDropdownField<String>(
          fieldId: fieldId,
          value: value,
          labelText: labelText,
          items: items,
          onChanged: onChanged = null,
          // productId: _currentProductId,
        );
      },
    );
  }

  // ======= PREMIUM SUBMIT BUTTON =======
  Widget _buildSubmitButton(AppLocalizations loc, ColorScheme colorScheme) {
    return Consumer<AssistantNotifier>(
      builder: (context, assistantNotifier, child) {
        final isLoading = assistantNotifier.isLoading;
        final confidence = 0.9;
        final hasAiData = true;

        return Column(
          children: [
            if (hasAiData) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Assistant',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${(confidence * 100).toStringAsFixed(0)}% fields filled automatically',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary),
                        ),
                      )
                    : Text(
                        loc.submitText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        final product = Product(
          id_product: _idProduct ?? 0,
          product_provider_id: _selectedProviderId,
          product_quantifier:
              _productQuantifier ?? GluttexConstants.productUnits.first,
          product_owner_id: _productOwnerId ?? 1,
          id_product_category: _productTypeId ?? _productCategoryId ?? 1,
          product_category_id: _productTypeId ?? _productCategoryId ?? 1,
          id_product_image: _idProductImage,
          product_ref_id: _idProduct,
          product_name: _productName ?? '',
          product_brand: _productBrand ?? '',
          product_barcode: _productBarcode ?? '',
          product_image_url: _imageUrl,
          product_category_desc: '',
          product_price: _productPrice ?? 0.0,
          product_quantity: _productQuantity ?? 0,
          product_description: _productDescription ?? '',
          product_created_at: null,
          product_last_updated: null,
        );

        // Handle image upload
        if (_productImage != null) {
          product.productImage = _productImage!;
        } else if (product.id_product == 0) {
          final finalImageUrl = await Navigator.pushNamed(
            context,
            AppRoutes.imageUpload,
            arguments: {
              "entity": "product",
              "id": product.id_product,
            },
          ) as String?;

          if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
            product.product_image_url = finalImageUrl;
          }
        }

        await Provider.of<ProductNotifier>(context, listen: false)
            .addOrUpdateProduct(product);

        ResponseHandler.handleResponse(
          context: context,
          statusCode: 200,
          responseCode: GluttexResponseCodes.put_success,
          finalMessage: AppLocalizations.of(context)!.putSuccess,
        );

        if (mounted) {
          Navigator.popUntil(
            context,
            (route) => route.settings.name == AppRoutes.home,
          );
        }
      }
    } on GluttexException catch (e) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: e.statusCode ?? 500,
        responseCode: e.message,
        finalMessage: e.error,
      );
    } catch (e) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 500,
        responseCode: 'UNKNOWN_ERROR',
        finalMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<AssistantNotifier>(
      builder: (context, assistantNotifier, child) {
        final isLoading = assistantNotifier.isLoading;

        return Scaffold(
          appBar: AppBar(
            title:
                Text(_updatePage ? loc.updateProductText : loc.addProductTxt),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            centerTitle: false,
          ),
          floatingActionButton: isLoading
              ? null
              : FloatingActionButton(
                  onPressed: _showAiAssistanceOptions,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(Icons.auto_awesome),
                ),
          body: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.surface,
                      colorScheme.surfaceVariant.withOpacity(0.3),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // AI Assistance Button
                      if (!_updatePage) _buildAiAssistanceButton(loc),

                      // Image Picker
                      if (_productImage != null)
                        ImagePickerSection(
                          initialImageUrl: _imageUrl ?? "",
                          entityType: 'product',
                          ownerId: '$_productOwnerId',
                          entityId: '$_idProduct',
                          onImageUploaded: (newImage) {
                            setState(() {
                              _productImage = newImage;
                              _idProductImage = 0;
                            });
                          },
                          capturedImageFile: _productImageFile,
                        ),

                      const SizedBox(height: 24),

                      // Product Name - Smart Field
                      _buildSmartFormField(
                        fieldId: ProductAssistedFields.IPRODUCT_NAME,
                        controller: _nameController,
                        labelText: loc.productNameTxt,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.pleaseInputProductNameMsg;
                          }
                          return null;
                        },
                        onSaved: (value) => _productName = value,
                      ),

                      const SizedBox(height: 16),

                      // Product Brand - Smart Field
                      _buildSmartFormField(
                        fieldId: ProductAssistedFields.IPRODUCT_BRAND,
                        controller: _brandController,
                        labelText: loc.productBrandTxt,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.pleaseInputProductBrandMsg;
                          }
                          return null;
                        },
                        onSaved: (value) => _productBrand = value,
                      ),

                      const SizedBox(height: 16),

                      // Barcode with scanner - Smart Field
                      _buildSmartFormField(
                        fieldId: ProductAssistedFields.IPRODUCT_BARCODE,
                        controller: _barcodeController,
                        labelText: loc.productBarcodeTxt,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.pleaseInputProductBarcodeMsg;
                          }
                          return null;
                        },
                        onSaved: (value) => _productBarcode = value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            CupertinoIcons.barcode_viewfinder,
                            color: colorScheme.primary,
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final scannedCode = await Navigator.pushNamed(
                                    context,
                                    AppRoutes.productScanPage,
                                  ) as String?;

                                  if (scannedCode != null &&
                                      scannedCode.isNotEmpty) {
                                    setState(() {
                                      _productBarcode = scannedCode;
                                      _barcodeController.text = scannedCode;
                                    });
                                  }
                                },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Price - Smart Field
                      _buildSmartFormField(
                        fieldId:
                            ProductAssistedFields.IPRODUCT_ESTIMATED_PRICE_DA,
                        controller: _priceController,
                        labelText: loc.productPriceTxt,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.pleaseInputProductNameMsg;
                          }
                          if (double.tryParse(value) == null) {
                            return loc.pleaseInputvalidnumberMsg;
                          }
                          if (double.tryParse(value)! >= 1000000) {
                            return loc.numberConstraintMsg;
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            _productPrice = double.tryParse(value ?? "0.0"),
                      ),

                      const SizedBox(height: 16),

                      // Quantity - Smart Field
                      _buildSmartFormField(
                        fieldId: ProductAssistedFields.QUANTITY,
                        controller: _quantityController,
                        labelText: loc.productQuantityText,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.pleaseInputProductNameMsg;
                          }
                          if (int.tryParse(value) == null) {
                            return loc.pleaseInputProductNameMsg;
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            _productQuantity = int.tryParse(value ?? "0"),
                      ),

                      const SizedBox(height: 16),

                      // Quantifier Dropdown - Smart Field
                      _buildSmartDropdownField(
                          fieldId: ProductAssistedFields.QUANTIFIER,
                          value: _productQuantifier ??
                              GluttexConstants.productUnits.first,
                          labelText: loc.unitText,
                          items: GluttexConstants.productUnits.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(_getUnitText(unit, loc)),
                            );
                          }).toList(),
                          onChanged: isLoading
                              ? (value) {
                                  if (value != null) {
                                    setState(() {
                                      _productQuantifier = value;
                                    });
                                  }
                                }
                              : null),

                      const SizedBox(height: 16),

                      // Description - Smart Field
                      _buildSmartFormField(
                        fieldId: ProductAssistedFields.DESCRIPTION,
                        controller: _descriptionController,
                        labelText: loc.productDescriptionText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.pleaseInputProductDescriptionMsg;
                          }
                          if (value.length >= 300) {
                            return loc.descriptionCharacterConstraintMsg;
                          }
                          return null;
                        },
                        onSaved: (value) => _productDescription = value,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

                      // Category Picker
                      CategoryPicker(
                        category_id: _productCategoryId ?? 1,
                        categories:
                            Provider.of<ProductNotifier>(context).categories,
                        onCategoryChanged: _onCategoryChanged,
                        pathFunction: (int id) => 'assets/icons/$id.svg',
                        package: "medicom_catalog",
                      ),

                      const SizedBox(height: 24),

                      // Supplier Picker
                      SupplierPicker(
                        onSupplierChanged: (selectedSupplier) {
                          setState(() {
                            _selectedProviderId =
                                selectedSupplier.idProductProvider;
                          });
                        },
                        suppliers: _supplierNotifier.suppliers
                            .where((s) =>
                                s?.productProviderOwnerId ==
                                _userNotifier.appUser?.id_app_user)
                            .whereType<Supplier>()
                            .toList(),
                        initialSelection: _initialSupplier,
                      ),

                      const SizedBox(height: 32),

                      // Submit Button with AI Confidence
                      _buildSubmitButton(loc, colorScheme),
                    ],
                  ),
                ),
              ),

              // Loading Overlay
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary),
                                  strokeWidth: 4,
                                ),
                              ),
                              Icon(
                                Icons.auto_awesome,
                                size: 32,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            loc.aiAnalysing,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.waitText,
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
