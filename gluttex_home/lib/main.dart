import 'package:flutter/material.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_home/screens/home_screen.dart';
import 'package:gluttex_impl_app/gluttex_impl_app.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_impl_business/gluttex_impl_product.dart';
import 'package:gluttex_impl_business/gluttex_impl_recipe.dart';
import 'package:gluttex_impl_business/gluttex_impl_supplier.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:gluttex_impl_mediation/gluttex_impl_mediation.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

void setupLocator() {
  // Register your services or dependencies here
  GluttexLocator.registerSingletonService<StorageService>(StorageServiceImpl());
  GluttexLocator.registerSingletonService<AppUserService>(AppUserServiceImpl());
  GluttexLocator.registerSingletonService<RecipeService>(RecipeServiceImpl());
  GluttexLocator.registerSingletonService<SupplierService>(
      SupplierServiceImpl());
  GluttexLocator.registerSingletonService<ProductService>(ProductServiceImpl());
}

void main() {
  setupLocator();
  runApp(GluttexApp());
}

class GluttexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductNotifier>(
            create: (_) => ProductNotifier(),
          ),
          ChangeNotifierProvider<RecipeNotifier>(
            create: (_) => RecipeNotifier(),
          ),
          ChangeNotifierProvider<AppUserNotifier>(
            create: (_) => AppUserNotifier(),
          ),
        ],
        child: MaterialApp(
          home: HomePage(),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            /* dark theme settings */
          ),
          themeMode: ThemeMode.dark,
        ));
  }
}
