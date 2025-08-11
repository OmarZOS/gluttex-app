import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locator/locator.dart';
import 'package:medicom_catalog/screens/components/ImagePickerSection.dart';
import 'package:medicom_catalog/screens/components/category_picker.dart';
import 'package:provider/provider.dart';

class ProductEditFormScreen extends StatefulWidget {
  final String? initialProductName;
  final String? initialProductBrand;
  final String? initialProductBarcode;
  final Uint8List? initialProductImage;
  final String? initialProductImageUrl;
  final int? initialProductTypeId;
  final double? initialProductPrice;
  final int? initialProductQuantity;
  final int? initialProductOwner;

  final int? initialProduct_provider_id;
  final int? initialProduct_category_id;
  final int? initialIdProduct;
  final int? initialIdProductImage;
  final String? initialProductDescription;

  const ProductEditFormScreen(
      {Key? key,
      this.initialProductName,
      this.initialProductBrand,
      this.initialProductBarcode,
      this.initialProductImage,
      this.initialProductImageUrl,
      this.initialProductTypeId,
      this.initialProductPrice,
      this.initialProductQuantity,
      this.initialProductOwner,
      this.initialProduct_provider_id,
      this.initialProduct_category_id,
      this.initialIdProduct,
      this.initialIdProductImage,
      this.initialProductDescription})
      : super(key: key);

  @override
  _ProductEditFormScreenState createState() => _ProductEditFormScreenState();
}

class _ProductEditFormScreenState extends State<ProductEditFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _productName;
  String? _productBrand;
  String? _productBarcode;
  GluttexImage? _productImage = null;
  int? _productTypeId;
  double? _productPrice;
  int? _productQuantity;
  int? _product_owner_id;
  int? _product_provider_id;
  int? _product_category_id;
  int? _id_product;
  int? _id_product_image;
  String? imageUrl;
  String? _productDescription;
  DateTime? product_created_at;
  DateTime? product_last_updated;

  @override
  void initState() {
    super.initState();
    // Initialize state variables with initial values from the widget
    _productName = widget.initialProductName;
    _productBrand = widget.initialProductBrand;
    _productBarcode = widget.initialProductBarcode;
    // _productImage = widget.initialProductImage;
    imageUrl = widget.initialProductImageUrl ?? "";
    _productTypeId = widget.initialProductTypeId ?? 1;
    _productPrice = widget.initialProductPrice;
    _productQuantity = widget.initialProductQuantity;
    _product_owner_id = widget.initialProductOwner;
    _productDescription = widget.initialProductDescription;
    _product_provider_id = widget.initialProduct_provider_id;
    _product_category_id = widget.initialProduct_category_id;
    _id_product = widget.initialIdProduct;
    _id_product_image = widget.initialIdProductImage;
  }

  void _onCategoryChanged(int identifier) {
    _productTypeId = identifier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.updateProductText),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'floating-button',
        child: const Icon(
          Icons.shopify_sharp,
          // color: Colors.yellow[50],
        ),
        onPressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _productName,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.productNameTxt),
                onSaved: (value) => _productName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputProductNameMsg;
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _productBrand,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.productBrandTxt),
                onSaved: (value) => _productBrand = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputProductBrandMsg;
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _productBarcode,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.productBarcodeTxt),
                onSaved: (value) => _productBarcode = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputProductBarcodeMsg;
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: '$_productPrice',
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.productPriceTxt),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputProductNameMsg;
                  }
                  if (double.tryParse(value) == null) {
                    return AppLocalizations.of(context)!
                        .pleaseInputvalidnumberMsg;
                  }
                  if (double.tryParse(value)! >= 1000000) {
                    return AppLocalizations.of(context)!.numberConstraintMsg;
                  }
                  return null;
                },
                onSaved: (value) =>
                    _productPrice = double.tryParse(value ?? "0.0"),
              ),
              TextFormField(
                initialValue: '$_productQuantity',
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.productQuantityText),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _productQuantity = int.tryParse(value ?? "0"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputProductNameMsg;
                  }
                  if (int.tryParse(value) == null) {
                    return AppLocalizations.of(context)!
                        .pleaseInputProductNameMsg;
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _productDescription ?? "",
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.productDescriptionText),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputProductDescriptionMsg;
                  }

                  if ((value).length >= 300) {
                    return AppLocalizations.of(context)!
                        .descriptionCharacterConstraintMsg;
                  }
                  return null;
                },
                onSaved: (value) => _productDescription = value,
              ),
              const SizedBox(height: 16.0),
              CategoryPicker(
                category_id: _product_category_id ?? 1,
                categories: Provider.of<ProductNotifier>(context).categories!,
                onCategoryChanged: (selectedCategoryId) {
                  _onCategoryChanged(selectedCategoryId);
                },
              ),
              const SizedBox(height: 16.0),
              ImagePickerSection(
                initialImageUrl: imageUrl,
                entityType: 'product',
                ownerId: '$_product_owner_id',
                entityId: '$_id_product',
                onImageUploaded: (newImage) {
                  setState(() {
                    _productImage = newImage;
                    _id_product_image =
                        0; // Reset image ID to 0 for new uploads
                  });
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final product = Product(
                      id_product: _id_product,
                      product_provider_id: _product_provider_id,
                      product_owner_id: _product_owner_id,
                      product_category_id:
                          _productTypeId ?? _product_category_id,
                      id_product_category: _productTypeId,
                      id_product_image: _id_product_image,
                      product_ref_id: _id_product,
                      product_name: _productName,
                      product_brand: _productBrand,
                      product_barcode: _productBarcode,
                      product_image_url: imageUrl,
                      product_category_desc: '',
                      product_price: _productPrice ?? 0,
                      product_quantity: _productQuantity ?? 0,
                      product_description: _productDescription,
                      product_created_at: null,
                      product_last_updated: null,
                    );

                    if (_productImage != null)
                      // ignore: curly_braces_in_flow_control_structures
                      product.productImage = _productImage!;

                    final statusCode = await Provider.of<ProductNotifier>(
                            context,
                            listen: false)
                        .addOrUpdateProduct(product);

                    _handleResponse(statusCode);

                    // You can use a provider or any state management to save the product
                  }
                },
                child: Text(AppLocalizations.of(context)!.submitText),
              ),
            ],
          ),
        ),
      ),
    );
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
}
