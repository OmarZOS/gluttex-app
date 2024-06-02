import 'package:flutter/material.dart';
import 'package:gluttex_core/business/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_impl_business/gluttex_impl_supplier.dart';
import 'package:gluttex_impl_mediation/gluttex_impl_mediation.dart';
import 'package:gluttex_localiser/screens/sliding_suppliers_widget.dart';

import 'package:locator/locator.dart';

void setupLocator() {
  // Register your services or dependencies here
  // For example:
  GluttexLocator.registerSingletonService<StorageService>(StorageServiceImpl());
  GluttexLocator.registerSingletonService<SupplierService>(
      SupplierServiceImpl());
}

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'GeoJSON Map',
      home: Scaffold(
        body: SlidingSuppliersWidget(),
      ),
    );
  }
}
