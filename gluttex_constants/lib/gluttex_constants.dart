library gluttex_constants;

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class GluttexConstants {
  // API endpoints
  static const String apiBaseUrl = 'http://192.168.14.158:9000';
  // static const String authApiBaseUrl = 'http://localhost:9090';

  static const String addAppUserEndpoint = '/appUser/add';
  static const String deleteAppUserEndpoint = '/appUser/delete';
  static const String getAllAppUsersEndpoint = '/appUser';
  static const String appUserEndpoint = '/appUser';
  static const String getAppUserCategoriesEndpoint = '/appUser/Category/all';

  static const String addProductEndpoint = '/product/add';
  static const String deleteProductEndpoint = '/Product/delete';
  static const String getAllProductsEndpoint = '/Product/all';
  static const String productEndpoint = '/product';
  static const String getProductCategoriesEndpoint = '/product/Category/all';
  static const String getProductImageEndpoint = '/image/product';
  static const String getProductFeedEndpoint = '/products/observer';

  static const String addOrderEndpoint = '/business/order/add';
  // static const String deleteOrderEndpoint = '/Order/delete';
  // static const String getAllOrdersEndpoint = '/Order/all';
  // static const String orderEndpoint = '/Order';

  static const String addSupplierEndpoint = '/supplier/add';
  static const String deleteSupplierEndpoint = '/supplier/delete';
  static const String getAllSuppliersEndpoint = '/Supplier/all';
  static const String supplierEndpoint = '/supplier';
  static const String getSupplierCategoriesEndpoint = '/Supplier/Category/all';
  static const String getRecipeImageEndpoint = '/image/recipe';

  static const String addRecipeEndpoint = '/recipe/add';
  static const String getIngredientEndpoint = '/recipe/Ingredients/all';
  static const String deleteRecipeEndpoint = '/Recipe/delete';
  static const String getAllRecipesEndpoint = '/Recipe/all';
  static const String recipeEndpoint = '/recipe';
  static const String getRecipeCategoriesEndpoint = '/recipe/Category/all';

  static const String loginEndpoint = '/authentication/token';
  static const String productsEndpoint = '/products';

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
