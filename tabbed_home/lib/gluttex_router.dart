import 'package:flutter/material.dart';
import 'package:recipe_catalog/screens/ingredient_management_screen.dart';
import 'package:recipe_catalog/screens/recipe_catalog_screen.dart';
import 'package:recipe_catalog/screens/recipe_form_screen.dart';
import 'package:app_constants/app_constants.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:event/order_change_notifier.dart';
import 'package:tabbed_home/screens/app_user_update_form_screen.dart';
import 'package:tabbed_home/screens/home_screen.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider_geo/screens/supplier_form_page.dart';
import 'package:provider_geo/screens/suppliers_map_screen.dart';
import 'package:login/screens/login_screen.dart';
import 'package:login/screens/registration_screen.dart';
import 'package:provider_personnel/personnel_management_screen.dart';
// import 'package:provider_personnel/supplier_dashboard_screen.dart';
import 'package:provider_personnel/supplier_entities_screen.dart';
import 'package:scanner/screens/qr_scanner.dart';
import 'package:scanner/screens/barcode_scanner.dart';
import 'package:scanner/screens/product_scanner.dart';
import 'package:provider_store/components/service/form/provided_service_form_screen.dart';
import 'package:provider_store/screens/dashboard_screen.dart';
import 'package:product_catalog/screens/cart_screen.dart';
import 'package:product_catalog/screens/orders_screen.dart';
import 'package:product_catalog/screens/product_catalog_screen.dart';
import 'package:product_catalog/screens/product_form_screen.dart';
import 'package:product_catalog/screens/product_screen.dart';
// import 'package:product_catalog/screens/product_form_screen.dart';
import 'package:provider/provider.dart';

import 'screens/image_upload_screen.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    debugPrint('=== GENERATING ROUTE ===');
    debugPrint('Route name: ${settings.name}');
    debugPrint('Route arguments: ${settings.arguments}');

    return MaterialPageRoute(
      settings:
          settings, // Important: This preserves the route name in the stack
      builder: (context) {
        // Use Consumer to get the latest appUser state
        return Consumer<AppUserNotifier>(
          builder: (context, authProvider, child) {
            final appUser = authProvider.appUser;
            final isAuthenticated = authProvider.isAuthenticated;

            debugPrint(
                'Router - appUser: ${appUser?.idAppUser}, isAuthenticated: $isAuthenticated');

            final args = settings.arguments as Map<String, dynamic>?;

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
                debugPrint('Creating RecipeFormScreen route');
                return _buildGuardedRoute(
                  isAuthenticated,
                  const RecipeFormScreen(),
                  const RecipeCatalogScreen(),
                );
              case AppRoutes.cartPage:
                return _buildGuardedRoute(
                    isAuthenticated, const CartScreen(), const HomePage());
              case AppRoutes.providerCreate:
                return _buildGuardedRoute(
                  isAuthenticated,
                  const SupplierFormScreen(),
                  const SuppliersMapScreen(),
                );

              case AppRoutes.ingredientManagement:
                return _buildGuardedRoute(
                  isAuthenticated,
                  const IngredientManagementScreen(),
                  const RecipeCatalogScreen(),
                );

              case AppRoutes.supplierManage:
                return _buildGuardedRoute(
                  isAuthenticated,
                  PersonnelManagementScreen(
                    supplierName: args?['supplierName'],
                    orgId: args?['orgId'],
                    supplierId: args?['supplierId'],
                  ),
                  const SuppliersMapScreen(),
                );
              case AppRoutes.serviceForm:
                return const ProvidedServiceFormScreen();
              case AppRoutes.storeManage:
                return const DashboardScreen();
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

              // case AppRoutes.dashboardPage:
              //   return const SupplierDashboardScreen();
              case AppRoutes.supplierEntitiesPage:
                return const SupplierEntitiesScreen();

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
                  OrdersScreen(
                    cartChangeNotifier:
                        Provider.of<OrderChangeNotifier>(context),
                  ),
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
    );
  }

  static Widget _buildGuardedRoute(
    bool isAuthenticated,
    Widget authorizedScreen,
    Widget unauthorizedScreen,
  ) {
    // Add key to help with debugging
    return isAuthenticated
        ? SizedBox(
            key: Key('authorized_${authorizedScreen.runtimeType}'),
            child: authorizedScreen)
        : SizedBox(
            key: Key('unauthorized_${unauthorizedScreen.runtimeType}'),
            child: unauthorizedScreen);
  }
}
