import 'package:flutter/material.dart';
import 'package:recipe_catalog/screens/recipe_catalog_screen.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:event/recipe_change_notifier.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

void setupLocator() {
  // Register your services or dependencies here
  // For example:
  // AppLocator.registerSingletonService<AppUserService>(AppUserServiceImpl());
  // AppLocator.registerSingletonService<RecipeService>(
  //     RecipeServiceImpl() as RecipeService);
  // AppLocator.registerSingletonService<StorageService>(StorageServiceImpl());
  // AppLocator.registerSingletonService<SupplierService>(
  //     SupplierServiceImpl());
}

void main() {
  setupLocator();
  runApp(
    ChangeNotifierProvider(
      create: (context) => RecipeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My App',
      // darkTheme: ThemeData.dark(), // Default dark theme
      home: RecipeCatalogScreen(),
    );
  }
}
