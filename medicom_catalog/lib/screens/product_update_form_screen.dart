import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locator/locator.dart';
import 'package:medicom_catalog/screens/components/category_picker.dart';
import 'package:provider/provider.dart';

import 'components/image_picker.dart';

class ProductEditFormScreen extends StatefulWidget {
  final String? initialProductName;
  final String? initialProductBrand;
  final String? initialProductBarcode;
  final Uint8List? initialProductImage;
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
  Uint8List? _productImage;
  int? _productTypeId;
  double? _productPrice;
  int? _productQuantity;
  int? _product_owner_id;
  int? _product_provider_id;
  int? _product_category_id;
  int? _id_product;
  int? _id_product_image;

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
    _productImage = widget.initialProductImage;
    _productTypeId = widget.initialProductTypeId ?? 1;
    _productPrice = widget.initialProductPrice;
    _productQuantity = widget.initialProductQuantity;
    _product_owner_id == widget.initialProductOwner;
    _productDescription = widget.initialProductDescription;
    _product_provider_id = widget.initialProduct_provider_id;
    _product_category_id = widget.initialProduct_category_id;
    _id_product = widget.initialIdProduct;
    _id_product_image = widget.initialIdProductImage;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageData = await pickedFile.readAsBytes();
      Uint8List resizedImage = resizeImage(
          imageData,
          MediaQuery.of(context).size.width.floor(),
          MediaQuery.of(context).size.width.floor());
      setState(() {
        _productImage = resizedImage;
      });
    }
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
              FutureBuilder<List<ProductCategory>?>(
                future: GluttexLocator.get<ProductService>().getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Show a loading indicator while waiting
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                        AppLocalizations.of(context)!.categoriesNotFoundTxt);
                  } else {
                    return CategoryPicker(
                      category_id: _productTypeId ?? 1,
                      categories: snapshot.data!,
                      onCategoryChanged: (selectedCategoryId) {
                        _onCategoryChanged(selectedCategoryId);
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16.0),
              _productImage != null
                  ? Image.memory(_productImage!,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width)
                  : Text(AppLocalizations.of(context)!.noImageSelectedTxt),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(AppLocalizations.of(context)!.pickImageMsg),
              ),
              const SizedBox(height: 20),
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
                      product_image_data: _productImage,
                      product_image_url: null,
                      product_category_desc: '',
                      product_price: _productPrice ?? 0,
                      product_quantity: _productQuantity ?? 0,
                      product_description: _productDescription,
                      product_created_at: null,
                      product_last_updated: null,
                    );

                    // Handle product submission
                    int? statusCode = await GluttexLocator.get<ProductService>()
                        .updateProduct(product);

                    Response response = Response();

                    switch (statusCode) {
                      case 200:
                        response.color = Colors.green;
                        response.text =
                            AppLocalizations.of(context)!.putSuccess;
                        await Provider.of<ProductNotifier>(context,
                                listen: false)
                            .fetchProducts(0);
                        Navigator.pop(context, product);
                        break;
                      case 406:
                        response.color = Colors.amberAccent;
                        response.text =
                            'Error $statusCode: ${AppLocalizations.of(context)!.putFailure}';
                        break;
                      case 422:
                        response.color = Colors.amberAccent;
                        response.text =
                            'Error $statusCode: ${AppLocalizations.of(context)!.putFailure}';
                        break;

                      default:
                        response.color = Colors.red;
                        response.text =
                            'Error $statusCode: ${AppLocalizations.of(context)!.serverError}';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.text),
                        backgroundColor: response.color,
                      ),
                    );

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
}
