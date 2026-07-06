import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/product_form_data.dart';
import 'package:event/user_change_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:product_catalog/screens/components/form/form_controllers.dart';
import 'package:provider/provider.dart';

class FormStateManager {
  final ProductFormData formData;
  final FormControllers controllers;
  bool initialized = false;
  bool isUpdate = false;

  FormStateManager({
    required this.formData,
    required this.controllers,
  });

  void initialize() {
    // Set default values
    formData.quantifier = 'pc';
    formData.categoryId = 1;
  }

  void initializeFromArguments(BuildContext context) {
    if (initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Product? product = args?['product'];

    if (product != null) {
      isUpdate = true;
      formData.populateFromProduct(product);
      controllers.syncWithFormData(formData);
    }

    // Set owner ID from current user
    final userNotifier = context.read<AppUserNotifier>();
    formData.ownerId = userNotifier.appUser?.idAppUser;

    // Set initial supplier
    final supplierNotifier = context.read<SupplierChangeNotifier>();
    final suppliers = supplierNotifier.suppliers
        .where((s) => s?.productProviderOwnerId == formData.ownerId)
        .whereType<Supplier>()
        .toList();

    if (suppliers.isNotEmpty) {
      formData.selectedProviderId = suppliers.first.idProductProvider;
    }

    initialized = true;
  }
}
