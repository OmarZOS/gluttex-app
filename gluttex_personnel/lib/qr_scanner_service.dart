import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:gluttex_core/app/AppUser.dart';

class QRScannerService {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Handle scanned QR data
      print('Scanned QR: ${scanData.code}');
    });
  }

  void dispose() {
    controller?.dispose();
  }

  // Parse QR code data to AppUser (mock implementation)
  AppUser? parseQRData(String qrData) {
    try {
      // In real app, you would parse the QR data and fetch user from API
      // This is a mock implementation
      final mockUser = AppUser(
        id_app_user: 999,
        app_user_name: 'scanned.user',
        app_user_type_id: 4,
        app_user_type_desc: 'Supplier',
        idPerson: 9999,
        personFirstName: 'Scanned',
        personLastName: 'User',
        personDetailsId: 9999,
        personBirthDate: '1990-01-01',
        personGender: 'Unknown',
        personNationality: 'Unknown',
        idBloodType: 1,
        bloodTypeDesc: 'O+',
        idLocation: 1,
        locationLatitude: 0.0,
        locationLongitude: 0.0,
        locationName: 'Scanned Location',
        locationAddressId: 1,
        addressStreet: 'Scanned Street',
        addressCity: 'Scanned City',
        addressPostalCode: '00000',
        addressCountry: 'Scanned Country',
        app_user_image_url:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&h=150&fit=crop&crop=face',
        app_user_person_id: null,
        app_user_password: '',
        app_user_preferences: '',
      );
      return mockUser;
    } catch (e) {
      print('Error parsing QR data: $e');
      return null;
    }
  }
}
