import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _productName;
  String? _productBrand;
  String? _productBarcode;
  Uint8List? _productImage;
  int? _product_type_id;
  double? _productPrice;
  int? _productQuantity;

  String? _productDescription;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageData = await pickedFile.readAsBytes();
      Uint8List resizedImage = resizeImage(imageData, 195, 195);
      setState(() {
        _productImage = resizedImage;
      });
    }
  }

  void _onCategoryChanged(int identifier) {
    _product_type_id = identifier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(GluttexConstants.addProductTxt),
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
                decoration: const InputDecoration(
                    labelText: GluttexConstants.productNameTxt),
                onSaved: (value) => _productName = value ?? "",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.pleaseInputProductNameMsg;
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: GluttexConstants.productBarcodeTxt),
                onSaved: (value) => _productBrand = value ?? "",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.pleaseInputProductBrandMsg;
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: GluttexConstants.productBarcodeTxt),
                onSaved: (value) => _productBarcode = value ?? "",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.pleaseInputProductBarcodeMsg;
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: GluttexConstants.productPriceTxt),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.pleaseInputProductPriceMsg;
                  }
                  if (double.tryParse(value) == null) {
                    return GluttexConstants.pleaseInputvalidnumberMsg;
                  }
                  if (double.tryParse(value)! >= 1000000) {
                    return GluttexConstants.numberConstraintMsg;
                  }
                  return null;
                },
                onSaved: (value) =>
                    _productPrice = double.tryParse(value ?? "0.0"),
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: GluttexConstants.ProductQuantityText),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _productQuantity = int.tryParse(value ?? "0"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.ProductQuantityText;
                  }
                  if (int.tryParse(value) == null) {
                    return GluttexConstants.pleaseInputProductQuantityMsg;
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: GluttexConstants.ProductDescriptionText),
                // keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null) {
                    if ((value).length >= 300) {
                      return GluttexConstants.descriptionCharacterConstraintMsg;
                    }
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
                    return const Text(GluttexConstants.categoriesNotFoundTxt);
                  } else {
                    return CategoryPicker(
                      category_id: _product_type_id ?? 1,
                      categories: snapshot.data!,
                      onCategoryChanged: (selectedCategoryId) {
                        _onCategoryChanged(selectedCategoryId);
                        //log('Selected category ID: $selectedCategoryId');
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _productImage != null
                  ? Image.memory(_productImage!,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width)
                  : const Text(GluttexConstants.noImageSelectedTxt),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text(GluttexConstants.pickImageMsg),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final product = Product(
                      id_product: 0,
                      product_provider_id: 1,
                      product_category_id: _product_type_id ?? 0,
                      id_product_category: _product_type_id ?? 0,
                      id_product_image: 0,
                      product_ref_id: 0,
                      product_name: _productName,
                      product_brand: _productBrand,
                      product_barcode: _productBarcode,
                      product_image_data: _productImage,
                      product_category_desc: '',
                      product_price: _productPrice ?? 0.0,
                      product_quantity: _productQuantity ?? 0,
                      product_description: _productDescription,
                      product_created_at: null,
                      product_last_updated: null,
                    );
                    // Handle product submission
                    int? statusCode;
                    Response response = Response();
                    try {
                      int? statusCode = await Provider.of<ProductNotifier>(
                              context,
                              listen: false)
                          .addProduct(product);

                      switch (statusCode) {
                        case 200:
                          response.color = Colors.green;
                          response.text = GluttexConstants.putSuccess;
                          await Provider.of<ProductNotifier>(context,
                                  listen: false)
                              .fetchProducts();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response.text),
                              backgroundColor: response.color,
                            ),
                          );
                          Navigator.pop(context);
                          break;
                        case 406:
                          response.color = Colors.amberAccent;
                          response.text = 'Error $statusCode: ' +
                              GluttexConstants.putFailure;
                          break;
                        case 422:
                          response.color = Colors.amberAccent;
                          response.text = 'Error $statusCode: ' +
                              GluttexConstants.putFailure;
                          break;

                        default:
                          response.color = Colors.red;
                          response.text = 'Error $statusCode: ' +
                              GluttexConstants.serverError;
                      }
                    } catch (e, stacktrace) {
                      log("$stacktrace");
                      response.color = Colors.red;
                      response.text = 'Error ${statusCode!}: ' +
                          GluttexConstants.serverError;
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
                child: const Text(GluttexConstants.submitText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
