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

    // ── Read the update payload (if any).
    final Product? product = args?['product'];
    if (product != null) {
      isUpdate = true;
      formData.populateFromProduct(product);
      controllers.syncWithFormData(formData);
    }

    // ── Read the provider hint from arguments.
    final rawProviderId = args?['providerId'];
    final providerId = rawProviderId is int
        ? rawProviderId
        : int.tryParse('${rawProviderId ?? ''}') ?? 0;
    final lockProvider = args?['lockProvider'] == true;

    // ── Set owner ID from current user.
    final userNotifier = context.read<AppUserNotifier>();
    formData.ownerId = userNotifier.appUser?.idAppUser;

    // ── Resolve the initial supplier.
    //
    // Priority:
    //   1. Provider from arguments (caller knows best)
    //   2. Provider from the product being edited (populateFromProduct set it)
    //   3. First supplier owned by the current user
    //
    // Only fall back to the heuristic when neither 1 nor 2 supplied a value,
    // otherwise we'd overwrite the caller's intent.
    if (providerId > 0) {
      formData.selectedProviderId = providerId;
      formData.providerId = providerId;
      formData.lockProvider = lockProvider;
    } else if (formData.selectedProviderId <= 0) {
      final supplierNotifier = context.read<SupplierChangeNotifier>();
      final suppliers = supplierNotifier.suppliers
          .where((s) => s?.productProviderOwnerId == formData.ownerId)
          .whereType<Supplier>()
          .toList();

      if (suppliers.isNotEmpty) {
        formData.selectedProviderId = suppliers.first.idProductProvider;
        formData.providerId = suppliers.first.idProductProvider;
      }
    }

    // If the product was loaded via `populateFromProduct`, it already set
    // `lockProvider = true`. Don't override that when no arguments lock
    // was requested.
    // (Handled above: we only assign lockProvider when providerId > 0.)

    initialized = true;
  }
}
