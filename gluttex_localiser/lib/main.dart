import 'package:flutter/material.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:gluttex_core/business/ProductService.dart';
import 'package:gluttex_core/business/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_impl_app/gluttex_impl_app.dart';
import 'package:gluttex_impl_business/gluttex_impl_product.dart';
import 'package:gluttex_impl_business/gluttex_impl_supplier.dart';
import 'package:gluttex_impl_mediation/gluttex_impl_mediation.dart';
import 'package:gluttex_localiser/map_locations_screen.dart';
import 'package:gluttex_localiser/swiper_widget.dart';
import 'package:locator/locator.dart';

void setupLocator() {
  // Register your services or dependencies here
  // For example:
  Locator.registerSingletonService<UserService>(UserServiceImpl());
  Locator.registerSingletonService<ProductService>(ProductServiceImpl());
  Locator.registerSingletonService<StorageService>(StorageServiceImpl());
  Locator.registerSingletonService<SupplierService>(SupplierServiceImpl());
}

void main() {
  setupLocator(); // Initialize the service locator
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'GeoJSON Map', home: SwipeFloatingWidget());
  }
}
