import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:gluttex_ui/components/confirmation_dialogue.dart';
// import 'package:gluttex_ui/components/SupplierProductCard.dart';

void showDeleteConfirmation(BuildContext context,
    SupplierChangeNotifier supplierNotifer, int idProductProvider) {
  showConfirmationDialog(
    context,
    AppLocalizations.of(context)!.recipedeletionConfirmationMessage,
    () async {
      try {
        await supplierNotifer.deleteSupplier(idProductProvider);
        ResponseHandler.handleResponse(
          context: context,
          statusCode: 200,
          responseCode: "SUCCESS",
          finalMessage: AppLocalizations.of(context)!.deleteSuccess,
        );
        Navigator.pop(context);
      } on GluttexException catch (e) {
        ResponseHandler.handleResponse(
          context: context,
          statusCode: e.statusCode ?? 300,
          responseCode: e.message,
          finalMessage: AppLocalizations.of(context)!.deleteFailure,
        );
      }
    },
  );
}
