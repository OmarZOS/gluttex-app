library gluttex_constants;

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class GluttexConstants {
  // API endpoints
  static const String apiBaseUrl = 'http://localhost:9000';
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
  static const String welcomeMessage = 'Welcome to MyApp!';
  static const String appName = 'MyApp';
  static const String errorOccurred =
      'An error occurred. Please try again later.';
  static const String noProductsFound = 'No products to display.';
  static const String addToCart = 'Add';
  static const String aboutProvider = 'About';
  static const String productQuantity = 'Quantity';
  static const String productReference = 'Reference';
  static const String priceText = 'Price';
  static const String noRecipesFound = 'No recipes found';
  static const String noAppUsersFound = 'No users found';

  // Responses
  static const String deleteSuccess = 'Successfully deleted item';
  static const String putSuccess = 'Successfully added item';
  static const String updateSuccess = 'Successfully updated item';

  // Exceptions
  static const String serverError = 'Failed to connect to the server';
  static const String notFoundError = 'Object not found';
  static const String deleteFailure = 'Failed to delete storage item';
  static const String getFailure = 'Failed to load item';
  static const String putFailure = 'Failed to add item';
  static const String updateFailure = 'Failed to update item';

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
