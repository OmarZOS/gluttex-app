// SnackbarService.dart
import 'package:flutter/material.dart';

class SnackbarService {
  static void showSnackbar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
      ),
    );
  }

  static void showSnackbarWithAction({
    required BuildContext context,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
        action: SnackBarAction(
          label: actionLabel,
          onPressed: onAction,
          textColor: Colors.white,
        ),
      ),
    );
  }

  static Color getSnackbarColorFromStatusCode(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    }
    switch (statusCode) {
      case 400:
        return Colors.orange;
      case 401:
      case 403:
        return Colors.redAccent;
      case 404:
        return Colors.orange;
      case 408:
      case 504:
        return Colors.amber;
      case 409:
      case 410:
      case 422:
        return Colors.deepOrange;
      case 429:
        return Colors.purple;
      case 500:
      case 502:
      case 503:
      case 511:
        return Colors.red;
      default:
        return Colors.grey[800]!;
    }
  }
}
