import 'package:flutter/material.dart';

class SnackbarService {
  static void showSnackbar({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Color getSnackbarColorFromStatusCode(
    int statusCode, {
    Color? successColor,
    Color? clientErrorColor,
    Color? authErrorColor,
    Color? serverErrorColor,
    Color? defaultColor,
  }) {
    final colors = _SnackbarColors(
      success: successColor,
      clientError: clientErrorColor,
      authError: authErrorColor,
      serverError: serverErrorColor,
      defaultColor: defaultColor,
    );

    if (statusCode >= 200 && statusCode < 300) {
      return colors.success;
    } else if (statusCode >= 400 && statusCode < 500) {
      if (statusCode == 401 || statusCode == 403) {
        return colors.authError;
      }
      return colors.clientError;
    } else if (statusCode >= 500) {
      return colors.serverError;
    }
    return colors.defaultColor;
  }
}

class _SnackbarColors {
  final Color success;
  final Color clientError;
  final Color authError;
  final Color serverError;
  final Color defaultColor;

  _SnackbarColors({
    Color? success,
    Color? clientError,
    Color? authError,
    Color? serverError,
    Color? defaultColor,
  })  : success = success ?? Colors.green.shade600,
        clientError = clientError ?? Colors.red.shade400,
        authError = authError ?? Colors.orange.shade600,
        serverError = serverError ?? Colors.red.shade800,
        defaultColor = defaultColor ?? Colors.blueGrey;
}
