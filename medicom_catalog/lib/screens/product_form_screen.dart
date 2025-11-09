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
  const ProductFormScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _productName;
  String? _productBrand;
  String? _productBarcode;
  GluttexImage? _productImage = null;
  int? _productTypeId;
  double? _productPrice;
  int? _productQuantity;
  String? _productQuantifier;
  int? _product_owner_id;
  int? _product_provider_id;
  int? _product_category_id;
  int? _id_product;
  int? _id_product_image;
  String? imageUrl;
  bool updatePage = false;
  String? _productDescription;
  DateTime? product_created_at;
  DateTime? product_last_updated;
  late SupplierChangeNotifier supplierNotifier;
  late AppUserNotifier userNotifier;
  int selectedProviderId = 0;

  late Supplier initialSupplier;

  bool _initialized = false; // to prevent re-initialization

  @override
  void initState() {
    super.initState();
    userNotifier = Provider.of<AppUserNotifier>(context, listen: false);

    supplierNotifier =
        Provider.of<SupplierChangeNotifier>(context, listen: false);

    List<Supplier?> supplierList = supplierNotifier.suppliers
        .where((s) =>
            s.productProviderOwnerId == userNotifier.appUser?.id_app_user)
        .toList();
    initialSupplier =
        (supplierList.isNotEmpty ? supplierList.first : Supplier.empty())!;
    selectedProviderId = initialSupplier.idProductProvider;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final Product? product = args?["product"];

      _productQuantifier = GluttexConstants.productUnits.first;
      _product_category_id = 1;

      if (product != null) {
        updatePage = true;
        _productName = product.product_name;
        _productBrand = product.product_brand;
        _productBarcode = product.product_barcode;
        imageUrl = product.product_image_url ?? "";
        _productTypeId = product.product_category_id ?? 1;
        _productPrice = product.product_price;
        _productQuantity = product.product_quantity;
        _productQuantifier = product.product_quantifier ?? "";
        _product_owner_id =
            product.product_owner_id ?? userNotifier.appUser!.id_app_user ?? 1;
        _productDescription = product.product_description;
        _product_provider_id = product.product_provider_id;
        _product_category_id = product.product_category_id;
        _id_product = product.id_product;
        _id_product_image = product.id_product_image;
      } else
        _product_owner_id = userNotifier.appUser!.id_app_user ?? 1;
    }
  }

  String _getUnitText(String unit, AppLocalizations loc) {
    switch (unit) {
      case 'g':
        return loc.quantifier_g;
      case 'kg':
        return loc.quantifier_kg;
      case 'mg':
        return loc.quantifier_mg;
      case 'L':
        return loc.quantifier_L;
      case 'mL':
        return loc.quantifier_mL;
      case 'pc':
        return loc.quantifier_pc;
      case 'pkg':
        return loc.quantifier_pkg;
      case 'box':
        return loc.quantifier_box;
      case 'bag':
        return loc.quantifier_bag;
      case 'slice':
        return loc.quantifier_slice;
      case 'cup':
        return loc.quantifier_cup;
      default:
        return loc.quantifier_pc;
    }
  }

  void _onCategoryChanged(int identifier) {
    _productTypeId = identifier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(updatePage
            ? AppLocalizations.of(context)!.updateProductText
            : AppLocalizations.of(context)!.addProductTxt),
      ),
      // floatingActionButton: FloatingActionButton(
      //   heroTag: 'floating-button-01',
      //   child: const Icon(
      //     Icons.shopify_sharp,
      //     // color: Colors.yellow[50],
      //   ),
      //   onPressed: () {},
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_id_product != null)
                ImagePickerSection(
                  initialImageUrl: (imageUrl ?? ""),
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
                initialValue: '${_productPrice ?? ''}',
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
                initialValue: '${_productQuantity ?? ''}',
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
              DropdownButtonFormField<String>(
                value: _productQuantifier, // 🔹 fallback to first unit
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.unitText,
                ),
                items: GluttexConstants.productUnits.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit, // 🔹 Save the raw unit (not the localized one)
                    child:
                        Text(_getUnitText(unit, AppLocalizations.of(context)!)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _productQuantifier = value; // 🔹 Save the raw code
                    });
                  }
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
                categories: Provider.of<ProductNotifier>(context).categories,
                onCategoryChanged: (selectedCategoryId) {
                  _onCategoryChanged(selectedCategoryId);
                },
                pathFunction: (int id) => 'assets/icons/$id.svg',
                package: "medicom_catalog",
              ),
              const SizedBox(height: 16.0),
              SupplierPicker(
                onSupplierChanged: (selectedSupplier) {
                  // Handle supplier selection
                  selectedProviderId = selectedSupplier.idProductProvider;
                  // print('Selected supplier: ${selectedSupplier.providerName}');
                },
                suppliers: supplierNotifier.suppliers
                    .where((s) =>
                        s.productProviderOwnerId ==
                        userNotifier.appUser!.id_app_user)
                    .toList(),
                initialSelection: initialSupplier,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Product product = Product(
                        id_product: _id_product ?? 0,
                        product_provider_id: selectedProviderId,
                        product_quantifier: _productQuantifier,
                        product_owner_id: userNotifier.appUser!.id_app_user,
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

                      String? finalImageUrl;

                      // Handle image logic
                      if (_productImage != null) {
                        // If we have a new image, set it directly
                        product.productImage = _productImage!;
                      } else if (product.id_product == 0) {
                        // If it's a new product without image, navigate to upload
                        finalImageUrl = await Navigator.pushNamed(
                            context, AppRoutes.imageUpload, arguments: {
                          "entity": "product",
                          "id": product.id_product
                        }) as String?;

                        // Update product with the uploaded image URL
                        if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
                          product.product_image_url = finalImageUrl;
                        }
                      }

                      // Save the product
                      await Provider.of<ProductNotifier>(context, listen: false)
                          .addOrUpdateProduct(product);

                      // Show success message
                      ResponseHandler.handleResponse(
                        context: context,
                        statusCode: 200,
                        responseCode: GluttexResponseCodes.put_success,
                        finalMessage: AppLocalizations.of(context)!.putSuccess,
                      );

                      // Navigate home only after everything is complete
                      if (mounted) {
                        Navigator.popUntil(context,
                            (route) => route.settings.name == AppRoutes.home);
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
                    // Handle any other unexpected errors
                    ResponseHandler.handleResponse(
                      context: context,
                      statusCode: 500,
                      responseCode: 'UNKNOWN_ERROR',
                      finalMessage:
                          'An unexpected error occurred: ${e.toString()}',
                    );
                  }
                },
                child: Text(AppLocalizations.of(context)!.submitText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary, // Button background color
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .onPrimary, // Text & icon color
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12), // optional
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
