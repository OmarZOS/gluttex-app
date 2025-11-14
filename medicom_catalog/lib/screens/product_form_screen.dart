import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_constants/gluttex_response_codes.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:gluttex_ui/components/supplier/supplier_picker.dart';
import 'package:gluttex_ui/components/ImagePickerSection.dart';
import 'package:gluttex_ui/components/category_picker.dart';
import 'package:provider/provider.dart';

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
  bool _isAiProcessing = false;
  int _selectedProviderId = 0;
  late Supplier _initialSupplier;
  late AppUserNotifier _userNotifier;
  late SupplierChangeNotifier _supplierNotifier;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeProviders();
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

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
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

  Future<void> _showAiAssistanceOptions() async {
    final option = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'AI Product Assistant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ListTile(
                leading: Icon(
                  CupertinoIcons.barcode_viewfinder,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Scan Barcode'),
                subtitle: const Text('Automatically fill details from barcode'),
                onTap: () => Navigator.pop(context, 1),
              ),
              ListTile(
                leading: Icon(
                  Icons.qr_code_scanner,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Scan QR Code'),
                subtitle: const Text('Automatically fill details from QR Code'),
                onTap: () => Navigator.pop(context, 2),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Take Product Photo'),
                subtitle: const Text('AI will analyze the product image'),
                onTap: () => Navigator.pop(context, 3),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (option != null) {
      await _handleAiAssistanceOption(option);
    }
  }

  Future<void> _handleAiAssistanceOption(int option) async {
    setState(() {
      _isAiProcessing = true;
    });

    try {
      if (option == 1) {
        await _handleBarcodeScanning();
      } else if (option == 2) {
        await _handleQRScanning();
      } else if (option == 3) {
        await _handleProductPhotoCapture();
      }
    } catch (e) {
      _showErrorSnackBar('AI assistance failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isAiProcessing = false;
        });
      }
    }
  }

  Future<void> _handleBarcodeScanning() async {
    final String? scannedCode = await Navigator.pushNamed(
      context,
      AppRoutes.productScanPage,
    ) as String?;

    if (scannedCode != null && scannedCode.isNotEmpty) {
      await _simulateAiProcessingWithBarcode(scannedCode);
    }
  }

  Future<void> _handleQRScanning() async {
    final String? scannedCode = await Navigator.pushNamed(
      context,
      AppRoutes.QRScanPage,
    ) as String?;

    if (scannedCode != null && scannedCode.isNotEmpty) {
      await _simulateAiProcessingWithBarcode(scannedCode);
    }
  }

  Future<void> _handleProductPhotoCapture() async {
    final File? capturedImage = await Navigator.pushNamed(
      context,
      AppRoutes.productCapturePage,
    ) as File?;

    if (capturedImage != null) {
      await _simulateAiProcessingWithImage(capturedImage);
    }
  }

  Future<void> _simulateAiProcessingWithBarcode(String barcode) async {
    await Future.delayed(const Duration(seconds: 2));
    final mockProductData = _getMockProductDataFromBarcode(barcode);

    if (mounted) {
      _updateFormWithAiData(mockProductData);
    }
  }

  Future<void> _simulateAiProcessingWithImage(File imageFile) async {
    await Future.delayed(const Duration(seconds: 3));
    final mockProductData = _getMockProductDataFromImage();

    if (mounted) {
      _updateFormWithAiData(mockProductData);
    }
  }

  Map<String, dynamic> _getMockProductDataFromBarcode(String barcode) {
    if (barcode.contains('613')) {
      return {
        'name': 'Organic Whole Wheat Bread',
        'brand': 'Nature\'s Best',
        'price': 4.99,
        'quantity': 1,
        'description': 'Fresh organic whole wheat bread with no preservatives',
        'category': 1,
        'unit': 'pc',
      };
    } else if (barcode.contains('456')) {
      return {
        'name': 'Almond Milk Unsweetened',
        'brand': 'PureHarvest',
        'price': 3.49,
        'quantity': 1,
        'description': 'Unsweetened almond milk, dairy-free and gluten-free',
        'category': 7,
        'unit': 'L',
      };
    } else {
      return {
        'name': 'Product from Barcode: $barcode',
        'brand': 'Unknown Brand',
        'price': 0.0,
        'quantity': 1,
        'description': 'Product information retrieved from barcode scan',
        'category': 1,
        'unit': 'pc',
      };
    }
  }

  Map<String, dynamic> _getMockProductDataFromImage() {
    return {
      'name': 'Gluten-Free Pasta',
      'brand': 'Healthy Choice',
      'price': 5.99,
      'quantity': 1,
      'description': 'Premium gluten-free pasta made from corn and rice flour',
      'category': 3,
      'unit': 'pkg',
    };
  }

  void _updateFormWithAiData(Map<String, dynamic> productData) {
    setState(() {
      _nameController.text = productData['name'] ?? '';
      _brandController.text = productData['brand'] ?? '';
      _priceController.text = (productData['price'] ?? 0.0).toString();
      _quantityController.text = (productData['quantity'] ?? 1).toString();
      _descriptionController.text = productData['description'] ?? '';
      _productQuantifier = productData['unit'] ?? 'pc';
      _productTypeId = productData['category'] ?? 1;
      _productCategoryId = productData['category'] ?? 1;

      _productName = productData['name'];
      _productBrand = productData['brand'];
      _productPrice = (productData['price'] ?? 0.0).toDouble();
      _productQuantity = productData['quantity'] ?? 1;
      _productDescription = productData['description'];
    });

    _showSuccessSnackBar('Product details filled automatically!');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAiAssistanceButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            Icons.auto_awesome,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'AI Product Assistant',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          subtitle: const Text('Automatically fill product details'),
          trailing: _isAiProcessing
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
              : Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: _isAiProcessing ? null : _showAiAssistanceOptions,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: suffixIcon,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onSaved: onSaved,
      ),
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

        // Handle image upload for new products
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_updatePage ? loc.updateProductText : loc.addProductTxt),
      ),
      floatingActionButton: _isAiProcessing
          ? null
          : FloatingActionButton(
              onPressed: _showAiAssistanceOptions,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.auto_awesome),
            ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // AI Assistance Button
                  if (!_updatePage) _buildAiAssistanceButton(),

                  // Image Picker
                  if (_idProduct != null)
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
                    ),

                  const SizedBox(height: 16),

                  // Product Name
                  _buildFormField(
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

                  // Product Brand
                  _buildFormField(
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

                  // Barcode with scanner
                  _buildFormField(
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
                      onPressed: () async {
                        final scannedCode = await Navigator.pushNamed(
                          context,
                          AppRoutes.productScanPage,
                        ) as String?;

                        if (scannedCode != null && scannedCode.isNotEmpty) {
                          setState(() {
                            _productBarcode = scannedCode;
                            _barcodeController.text = scannedCode;
                          });
                        }
                      },
                    ),
                  ),

                  // Price
                  _buildFormField(
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

                  // Quantity
                  _buildFormField(
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

                  // Quantifier Dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: _productQuantifier,
                      decoration: InputDecoration(
                        labelText: loc.unitText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: GluttexConstants.productUnits.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(_getUnitText(unit, loc)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _productQuantifier = value;
                          });
                        }
                      },
                    ),
                  ),

                  // Description
                  _buildFormField(
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

                  const SizedBox(height: 16.0),

                  // Category Picker
                  CategoryPicker(
                    category_id: _productCategoryId ?? 1,
                    categories:
                        Provider.of<ProductNotifier>(context).categories,
                    onCategoryChanged: _onCategoryChanged,
                    pathFunction: (int id) => 'assets/icons/$id.svg',
                    package: "medicom_catalog",
                  ),

                  const SizedBox(height: 16.0),

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

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAiProcessing ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        loc.submitText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // AI Processing Overlay
          if (_isAiProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'AI is analyzing your product...',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This may take a few seconds',
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
  }
}
