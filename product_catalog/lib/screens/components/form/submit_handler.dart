import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_response_codes.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/product_form_data.dart';
import 'package:event/product_change_notifier.dart';
import 'package:ui/Services/ResponseHandler.dart';
import 'package:product_catalog/screens/components/form/form_controllers.dart';
import 'package:provider/provider.dart';

// import '../data/product_form_data.dart';

class SubmitHandler {
  static Future<void> submitForm({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required ProductFormData formData,
    required FormControllers controllers,
    required bool isUpdate,
  }) async {
    try {
      if (formKey.currentState?.validate() == true) {
        formKey.currentState?.save();

        final product = formData.toProduct();
        final productNotifier = context.read<ProductNotifier>();

        await productNotifier.addOrUpdateProduct(product);

        ResponseHandler.handleResponse(
          context: context,
          statusCode: 200,
          responseCode: AppResponseCodes.put_success,
          finalMessage: AppLocalizations.of(context)!.putSuccess,
        );

        if (context.mounted) {
          Navigator.popUntil(
            context,
            (route) => route.settings.name == '/home',
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
}
