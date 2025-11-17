import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_catalog_screen.dart';
import 'package:gluttex_chef/screens/recipe_form_screen.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_home/screens/app_user_update_form_screen.dart';
import 'package:gluttex_home/screens/home_screen.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_localiser/screens/supplier_form_page.dart';
import 'package:gluttex_localiser/screens/suppliers_map_screen.dart';
import 'package:gluttex_login/screens/login_screen.dart';
import 'package:gluttex_login/screens/registration_screen.dart';
import 'package:gluttex_scanner/screens/qr_scanner.dart';
import 'package:gluttex_scanner/screens/barcode_scanner.dart';
import 'package:gluttex_scanner/screens/product_scanner.dart';
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
        // Use Consumer to get the latest appUser state
        return Consumer<AppUserNotifier>(
          builder: (context, authProvider, child) {
            final appUser = authProvider.appUser;
            final isAuthenticated = authProvider.isAuthenticated;

            print(
                'Router - appUser: $appUser, isAuthenticated: $isAuthenticated');

            switch (settings.name) {
              case AppRoutes.home:
                return _buildGuardedRoute(
                    isAuthenticated, const HomePage(), const LoginScreen());
              case AppRoutes.productCreate:
                return _buildGuardedRoute(
                  isAuthenticated,
                  const ProductFormScreen(),
                  const ProductCatalogScreen(),
                );
              case AppRoutes.productScanPage:
                return _buildGuardedRoute(
                  isAuthenticated,
                  BarcodeScannerScreen(
                    onBarcodeScanned: (String code) {},
                  ),
                  const ProductCatalogScreen(),
                );
              case AppRoutes.QRScanPage:
                return _buildGuardedRoute(
                  isAuthenticated,
                  QRScannerScreen(
                    onQRcodeScanned: (String code) {},
                  ),
                  const ProductCatalogScreen(),
                );
              case AppRoutes.productCapturePage:
                return _buildGuardedRoute(
                  isAuthenticated,
                  const ProductCaptureScreen(),
                  const ProductCatalogScreen(),
                );
              case AppRoutes.recipeCreate:
                return _buildGuardedRoute(isAuthenticated,
                    const RecipeFormScreen(), const RecipeCatalogScreen());
              case AppRoutes.cartPage:
                return _buildGuardedRoute(
                    isAuthenticated, const CartScreen(), const HomePage());
              case AppRoutes.providerCreate:
                return _buildGuardedRoute(
                  isAuthenticated,
                  const SupplierFormScreen(),
                  const SuppliersMapScreen(),
                );
              case AppRoutes.login:
                // If already authenticated, redirect to home
                if (isAuthenticated) {
                  return const HomePage();
                }
                return const LoginScreen();
              case AppRoutes.registration:
                return const RegistrationForm();
              case AppRoutes.imageUpload:
                return const UploadImagePage();
              case AppRoutes.productDetails:
                return const ProductDetailsScreen();
              case AppRoutes.userEdit:
                return _buildGuardedRoute(
                  isAuthenticated,
                  const AppUserEditFormScreen(),
                  const LoginScreen(),
                );
              case AppRoutes.ordersPage:
                return _buildGuardedRoute(
                  isAuthenticated,
                  const OrdersScreen(),
                  const LoginScreen(),
                );
              default:
                return _buildGuardedRoute(
                  isAuthenticated,
                  const HomePage(),
                  const LoginScreen(),
                );
            }
          },
        );
      },
      settings: settings,
    );
  }

  static Widget _buildGuardedRoute(
    bool isAuthenticated,
    Widget authorizedScreen,
    Widget unauthorizedScreen,
  ) {
    return isAuthenticated ? authorizedScreen : unauthorizedScreen;
  }
}
