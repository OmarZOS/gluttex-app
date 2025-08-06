import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicom_catalog/screens/components/ImagePickerSection.dart';
import 'package:medicom_catalog/screens/components/category_picker.dart';
import 'package:provider/provider.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productBrandController = TextEditingController();
  final _productBarcodeController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productQuantityController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  GluttexImage? _productImage;
  int? _productTypeId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _productBrandController.dispose();
    _productBarcodeController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();
    _productDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final product = Product(
        id_product: 0,
        product_provider_id: 1,
        product_category_id: _productTypeId ?? 1,
        id_product_category: _productTypeId ?? 1,
        id_product_image: 0,
        product_ref_id: 0,
        product_name: _productNameController.text,
        product_brand: _productBrandController.text,
        product_barcode: _productBarcodeController.text,
        product_image_url: null,
        product_category_desc: '',
        product_price: double.tryParse(_productPriceController.text) ?? 0.0,
        product_quantity: int.tryParse(_productQuantityController.text) ?? 0,
        product_description: _productDescriptionController.text,
        product_created_at: null,
        product_last_updated: null,
        product_owner_id: Provider.of<AppUserNotifier>(context, listen: false)
                .appUser!
                .id_app_user ??
            1,
      );

      if (_productImage != null)
        // ignore: curly_braces_in_flow_control_structures
        product.productImage = _productImage!;

      final statusCode =
          await Provider.of<ProductNotifier>(context, listen: false)
              .addOrUpdateProduct(product);

      _handleResponse(statusCode);
    } catch (e, stacktrace) {
      log("Form submission error: $stacktrace");
      _showSnackBar(
        '${AppLocalizations.of(context)!.serverError}: $e',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleResponse(int? statusCode) {
    final loc = AppLocalizations.of(context)!;
    String message;
    Color color;

    switch (statusCode) {
      case 200:
        message = loc.putSuccess;
        color = Colors.green;
        Provider.of<ProductNotifier>(context, listen: false).fetchProducts(0);
        Navigator.pop(context);
        break;
      case 406:
      case 422:
        message = '${loc.putFailure} (Error $statusCode)';
        color = Colors.amber;
        break;
      default:
        message = '${loc.serverError} (Error $statusCode)';
        color = Colors.red;
    }

    _showSnackBar(message, color);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.addProductTxt),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _productNameController,
                label: loc.productNameTxt,
                validator: (value) => value?.isEmpty ?? true
                    ? loc.pleaseInputProductNameMsg
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _productBrandController,
                label: loc.productBrandTxt,
                validator: (value) => value?.isEmpty ?? true
                    ? loc.pleaseInputProductBrandMsg
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _productBarcodeController,
                label: loc.productBarcodeTxt,
                validator: (value) => value?.isEmpty ?? true
                    ? loc.pleaseInputProductBarcodeMsg
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _productPriceController,
                label: loc.productPriceTxt,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return loc.pleaseInputProductPriceMsg;
                  final numValue = double.tryParse(value!);
                  if (numValue == null) return loc.pleaseInputvalidnumberMsg;
                  if (numValue >= 1000000) return loc.numberConstraintMsg;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _productQuantityController,
                label: loc.productQuantityText,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return loc.pleaseInputProductQuantityMsg;
                  if (int.tryParse(value!) == null)
                    return loc.pleaseInputvalidnumberMsg;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _productDescriptionController,
                label: loc.productDescriptionText,
                maxLines: 3,
                validator: (value) => (value?.length ?? 0) >= 300
                    ? loc.descriptionCharacterConstraintMsg
                    : null,
              ),
              const SizedBox(height: 24),
              CategoryPicker(
                category_id: 1,
                categories: Provider.of<ProductNotifier>(context).categories,
                onCategoryChanged: (id) => _productTypeId = id,
              ),
              const SizedBox(height: 24),
              ImagePickerSection(
                initialImageUrl: null,
                entityType: 'product',
                onImageUploaded: (image) {
                  setState(() {
                    _productImage = image;
                  });
                },
                ownerId:
                    '${Provider.of<AppUserNotifier>(context, listen: false).appUser!.id_app_user}',
                entityId: '0', // New product, so no ID yet
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : Text(loc.submitText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
