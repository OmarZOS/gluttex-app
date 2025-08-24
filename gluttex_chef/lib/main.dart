import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_catalog_screen.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_event/recipe_change_notifier.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

void setupLocator() {
  // Register your services or dependencies here
  // For example:
  // GluttexLocator.registerSingletonService<AppUserService>(AppUserServiceImpl());
  // GluttexLocator.registerSingletonService<RecipeService>(
  //     RecipeServiceImpl() as RecipeService);
  // GluttexLocator.registerSingletonService<StorageService>(StorageServiceImpl());
  // GluttexLocator.registerSingletonService<SupplierService>(
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
