import 'package:flutter/material.dart';

String? extractUserIdFromQR(String qrCode) {
  try {
    final parts = qrCode.split(':');
    if (parts.length < 2) return null;

    final userId = parts.last.trim();
    if (userId.isEmpty) return null;

    if (int.tryParse(userId) == null) return null;

    return userId;
  } catch (e) {
    debugPrint('Error extracting user ID from QR: $e');
    return null;
  }
}
