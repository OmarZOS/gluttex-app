import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_catalog_screen.dart';
import 'package:gluttex_chef/screens/recipe_form_screen.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_home/screens/home_screen.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_localiser/screens/business_form_page.dart';
import 'package:gluttex_localiser/screens/sliding_suppliers_widget.dart';
import 'package:gluttex_login/screens/login_screen.dart';
import 'package:gluttex_login/screens/registration_screen.dart';
import 'package:medicom_catalog/screens/catalog_screen.dart';
import 'package:medicom_catalog/screens/product_form_screen.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final appUser =
            Provider.of<AppUserNotifier>(context, listen: false).appUser;

        switch (settings.name) {
          case AppRoutes.home:
            return _buildGuardedRoute(
                appUser, const HomePage(), const LoginScreen());
          case AppRoutes.productCreate:
            return _buildGuardedRoute(
                appUser, const ProductFormScreen(), const CatalogScreen());
          case AppRoutes.recipeCreate:
            return _buildGuardedRoute(
                appUser, const RecipeFormScreen(), const RecipeCatalogScreen());
          case AppRoutes.providerCreate:
            return _buildGuardedRoute(appUser, const SupplierFormScreen(),
                const SlidingSuppliersWidget());
          case AppRoutes.login:
            return const LoginScreen();
          case AppRoutes.registration:
            return const RegistrationForm();
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
