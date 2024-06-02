import 'package:flutter/material.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:gluttex_core/business/ProductService.dart';
import 'package:gluttex_core/business/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_impl_app/gluttex_impl_app.dart';
import 'package:gluttex_impl_business/change_notifier.dart';
import 'package:gluttex_impl_business/gluttex_impl_product.dart';
import 'package:gluttex_impl_business/gluttex_impl_supplier.dart';
import 'package:gluttex_impl_mediation/gluttex_impl_mediation.dart';
import 'package:locator/locator.dart';
import 'package:medicom_catalog/screens/catalog_screen.dart';
import 'package:provider/provider.dart';

void setupLocator() {
  // Register your services or dependencies here
  // For example:
  GluttexLocator.registerSingletonService<UserService>(UserServiceImpl());
  GluttexLocator.registerSingletonService<ProductService>(
      ProductServiceImpl() as ProductService);
  GluttexLocator.registerSingletonService<StorageService>(StorageServiceImpl());
  GluttexLocator.registerSingletonService<SupplierService>(
      SupplierServiceImpl());
}

void main() {
  setupLocator();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProductNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      darkTheme: ThemeData.dark(), // Default dark theme
      home: const CatalogScreen(
        isRightToLeft: false,
      ),
    );
  }
}

  
// GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2, // Number of columns in grid view
//               // childAspectRatio:
//               //     0.7, // Adjust this value to make items smaller or larger
//             ),
//             itemCount:
//                 (await productService.getAllProducts() as List<dynamic>).length,
//             itemBuilder: (context, index) {
//               var product =
//                   (await productService.getAllProducts() as List<dynamic>)[index];
//               return ProductCard(product: product);
// // var product = productService.getAllProducts()[index];
//             })