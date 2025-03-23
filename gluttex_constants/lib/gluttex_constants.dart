library gluttex_constants;

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class GluttexConstants {
  // API endpoints
  static const String apiBaseUrl = 'http://134.199.240.34/api';
  static const String fsBaseUrl = 'http://134.199.240.34';

  // static const String authApiBaseUrl = 'http://localhost:9090';
  static const String addAppUserEndpoint = '/app_user';
  static const String deleteAppUserEndpoint = '/app_user/delete';
  static const String getAllAppUsersEndpoint = '/app_user';
  static const String appUserEndpoint = '/app_user';
  static const String getAppUserCategoriesEndpoint = '/app_user/categorie/all';

  static const String addProductEndpoint = '/product/add';
  static const String deleteProductEndpoint = '/product/delete';
  static const String getAllProductsEndpoint = '/product/all';
  static const String productEndpoint = '/product';
  static const String getProductCategoriesEndpoint = '/product/category/all';
  static const String getAllProductsByCategoryEndpoint = '/product/category';
  static const String getProductImageEndpoint = '/image/product';
  static const String getProductFeedEndpoint = '/product/observer';

  static const String addOrderEndpoint = '/business/order/add';
  static const String getAllOrdersEndpoint = '/business/user/orders/all';

  static const String addSupplierEndpoint = '/supplier/add';
  static const String deleteSupplierEndpoint = '/supplier/delete';
  static const String getAllSuppliersEndpoint = '/supplier/all';
  static const String supplierEndpoint = '/supplier';
  static const String getSupplierCategoriesEndpoint = '/supplier/category/all';
  static const String getRecipeImageEndpoint = '/image/recipe';

  static const String addRecipeEndpoint = '/recipe/add';
  static const String getIngredientEndpoint = '/recipe/ingredients/all';
  static const String deleteRecipeEndpoint = '/recipe/delete';
  static const String getAllRecipesEndpoint = '/recipe/all';
  static const String recipeEndpoint = '/recipe';
  static const String getRecipeCategoriesEndpoint = '/recipe/category/all';

  static const String loginEndpoint = '/authentication/token';
  static const String signUpEndpoint = '/app_user/add';
  static const String productsEndpoint = '/product';

  static const int itemsPerPage = 6;

  // Texts
  static const String notFoundError = 'Object not found';
  static const String getFailure = 'Failed to load item';
  static const String serverError = 'Failed to connect to the server';

  // Fonts
  static const String defaultFontFamily = 'Roboto';
  static const kTextColor = Color(0xFF535353);
  static const kTextLightColor = Color(0xFFACACAC);

  static const kDefaultPaddin = 20.0;
}

class AppRoutes {
  static const String login = '/login';
  static const String registration = '/registration';
  static const String home = '/home';
}
