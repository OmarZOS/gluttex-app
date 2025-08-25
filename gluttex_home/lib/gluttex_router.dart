import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_catalog_screen.dart';
import 'package:gluttex_chef/screens/recipe_form_screen.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_home/screens/app_user_update_form_screen.dart';
import 'package:gluttex_home/screens/home_screen.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_localiser/screens/supplier_form_page.dart';
import 'package:gluttex_localiser/screens/suppliers_map_screen.dart';
import 'package:gluttex_login/screens/login_screen.dart';
import 'package:gluttex_login/screens/registration_screen.dart';
import 'package:medicom_catalog/screens/cart_screen.dart';
import 'package:medicom_catalog/screens/orders_screen.dart';
import 'package:medicom_catalog/screens/product_catalog_screen.dart';
import 'package:medicom_catalog/screens/product_form_screen.dart';
import 'package:medicom_catalog/screens/product_screen.dart';
// import 'package:medicom_catalog/screens/product_form_screen.dart';
import 'package:provider/provider.dart';

import 'screens/image_upload_screen.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final appUser = context.read<AppUserNotifier>().appUser;

        switch (settings.name) {
          case AppRoutes.home:
            return _buildGuardedRoute(
                appUser, const HomePage(), const LoginScreen());
          case AppRoutes.productCreate:
            return _buildGuardedRoute(appUser, const ProductFormScreen(),
                const ProductCatalogScreen());
          case AppRoutes.recipeCreate:
            return _buildGuardedRoute(
                appUser, const RecipeFormScreen(), const RecipeCatalogScreen());
          case AppRoutes.cartPage:
            return _buildGuardedRoute(
                appUser, const CartScreen(), const HomePage());
          case AppRoutes.providerCreate:
            return _buildGuardedRoute(appUser, const SupplierFormScreen(),
                const SuppliersMapScreen());
          case AppRoutes.login:
            return const LoginScreen();
          case AppRoutes.registration:
            return const RegistrationForm();
          case AppRoutes.imageUpload:
            return const UploadImagePage();
          case AppRoutes.productDetails:
            return const ProductDetailsScreen();
          case AppRoutes.userEdit:
            return const AppUserEditFormScreen();
          case AppRoutes.ordersPage:
            return const OrdersScreen();
          // case AppRoutes.supplierDetails:
          //   final supplier = settings.arguments as Supplier;
          //   return SupplierDetailsSheet(
          //     supplier: supplier,
          //   );

          default:
            return const LoginScreen();
        }
      },
      settings: settings,
    );
  }

  static Widget _buildGuardedRoute(
      AppUser? appUser, Widget authorizedScreen, Widget unauthorizedScreen) {
    if (appUser != null) {
      return authorizedScreen;
    } else {
      return unauthorizedScreen;
    }
  }
}
