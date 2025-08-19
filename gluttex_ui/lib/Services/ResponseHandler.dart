import 'package:flutter/material.dart';
import 'SnackbarService.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

class ResponseHandler {
  static void handleResponse({
    required BuildContext context,
    required int statusCode,
    required String responseCode,
    required String finalMessage,
    Function? onRetry,
  }) {
    Color snackbarColor =
        SnackbarService.getSnackbarColorFromStatusCode(statusCode);

    switch (responseCode) {
      case 'INTERNAL_SERVER_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.internal_server_error,
            backgroundColor: snackbarColor);
        break;
      case 'HTTP_EXCEPTION':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.http_exception,
            backgroundColor: snackbarColor);
        break;
      case 'INTEGRITY_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.integrity_error,
            backgroundColor: snackbarColor);
        break;
      case 'DATA_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.data_error,
            backgroundColor: snackbarColor);
        break;
      case 'OPERATIONAL_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.operational_error,
            backgroundColor: snackbarColor);
        break;
      case 'PROGRAMMING_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.programming_error,
            backgroundColor: snackbarColor);
        break;
      case 'DATABASE_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.database_error,
            backgroundColor: snackbarColor);
        break;
      case 'INTERNAL_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.internal_error,
            backgroundColor: snackbarColor);
        break;
      case 'INTERFACE_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.interface_error,
            backgroundColor: snackbarColor);
        break;
      case 'STATEMENT_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.statement_error,
            backgroundColor: snackbarColor);
        break;
      case 'SQLALCHEMY_ERROR':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.sqlalchemy_error,
            backgroundColor: snackbarColor);
        break;
      case 'AUTH_REQUIRED':
        SnackbarService.showSnackbar(
            context: context,
            message: finalMessage,
            backgroundColor: snackbarColor);
        break;
      case 'INCORRECT_CREDENTIALS':
        SnackbarService.showSnackbar(
            context: context,
            message: AppLocalizations.of(context)!.incorrect_credentials,
            backgroundColor: snackbarColor);
        break;

      case 'NETWORK_TIMEOUT':
        SnackbarService.showSnackbar(
          context: context,
          message: "Network timeout, please check your connection.",
        );
        onRetry?.call();
        break;

      default:
        SnackbarService.showSnackbar(
            context: context,
            message: finalMessage,
            backgroundColor: snackbarColor);
        break;
    }
  }
}
