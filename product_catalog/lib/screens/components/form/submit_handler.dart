import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_response_codes.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/product_form_data.dart';
import 'package:event/product_change_notifier.dart';
import 'package:ui/Services/ResponseHandler.dart';
import 'package:product_catalog/screens/components/form/form_controllers.dart';
import 'package:provider/provider.dart';

class SubmitHandler {
  static Future<void> submitForm({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required ProductFormData formData,
    required FormControllers controllers,
    required bool isUpdate,
  }) async {
    try {
      if (formKey.currentState?.validate() != true) return;

      formKey.currentState?.save();

      final product = formData.toProduct();
      final productNotifier = context.read<ProductNotifier>();

      await productNotifier.addOrUpdateProduct(product);

      if (!context.mounted) return;

      ResponseHandler.handleResponse(
        context: context,
        statusCode: 200,
        responseCode: AppResponseCodes.put_success,
        finalMessage: AppLocalizations.of(context)!.putSuccess,
      );

      // Pop just the form and hand the saved product back to the caller.
      Navigator.of(context).pop(product);
    } on GluttexException catch (e) {
      if (!context.mounted) return;
      ResponseHandler.handleResponse(
        context: context,
        statusCode: e.statusCode ?? 500,
        responseCode: e.message,
        finalMessage: e.error,
      );
    } catch (e) {
      if (!context.mounted) return;
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 500,
        responseCode: 'UNKNOWN_ERROR',
        finalMessage: 'An unexpected error occurred: $e',
      );
    }
  }
}
