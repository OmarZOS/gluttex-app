import 'package:flutter/material.dart';
import 'package:gluttex_core/business/product_form_data.dart';

class FormControllers {
  final TextEditingController barcode = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController brand = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController quantity = TextEditingController();
  final TextEditingController description = TextEditingController();

  void dispose() {
    barcode.dispose();
    name.dispose();
    brand.dispose();
    price.dispose();
    quantity.dispose();
    description.dispose();
  }

  void syncWithFormData(ProductFormData formData) {
    name.text = formData.productName ?? '';
    brand.text = formData.productBrand ?? '';
    barcode.text = formData.productBarcode ?? '';
    price.text = formData.price?.toString() ?? '';
    quantity.text = formData.quantity?.toString() ?? '';
    description.text = formData.productDescription ?? '';
  }
}
