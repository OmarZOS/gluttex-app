library gluttex_constants;

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class GluttexConstants {
  final List<Map<String, dynamic>> _cardColors = [
    // Vibrant colors (0-11)
    {
      'name': 'Coral',
      'rgb': [255, 111, 97],
      'opacity': 1.0
    },
    // {
    //   'name': 'Peach',
    //   'rgb': [255, 179, 71],
    //   'opacity': 1.0
    // },
    // {
    //   'name': 'Lemon',
    //   'rgb': [255, 215, 0],
    //   'opacity': 1.0
    // },
    // {
    //   'name': 'Mint',
    //   'rgb': [152, 255, 152],
    //   'opacity': 1.0
    // },
    {
      'name': 'Teal',
      'rgb': [0, 150, 136],
      'opacity': 1.0
    },
    // {
    //   'name': 'SkyBlue',
    //   'rgb': [135, 206, 235],
    //   'opacity': 1.0
    // },
    {
      'name': 'Lavender',
      'rgb': [150, 123, 182],
      'opacity': 1.0
    },
    {
      'name': 'Lilac',
      'rgb': [200, 162, 200],
      'opacity': 1.0
    },
    {
      'name': 'Blush',
      'rgb': [254, 130, 140],
      'opacity': 1.0
    },
    {
      'name': 'Salmon',
      'rgb': [255, 140, 105],
      'opacity': 1.0
    },
    // {
    //   'name': 'Aqua',
    //   'rgb': [0, 255, 255],
    //   'opacity': 1.0
    // },
    {
      'name': 'Goldenrod',
      'rgb': [218, 165, 32],
      'opacity': 1.0
    },

    // Muted tones (12-21)
    {
      'name': 'Sage',
      'rgb': [188, 184, 138],
      'opacity': 1.0
    },
    {
      'name': 'Taupe',
      'rgb': [179, 139, 109],
      'opacity': 1.0
    },
    {
      'name': 'Slate',
      'rgb': [112, 128, 144],
      'opacity': 1.0
    },
    {
      'name': 'Mauve',
      'rgb': [224, 176, 255],
      'opacity': 1.0
    },
    {
      'name': 'Sand',
      'rgb': [244, 164, 96],
      'opacity': 1.0
    },
    {
      'name': 'Olive',
      'rgb': [128, 128, 0],
      'opacity': 1.0
    },
    {
      'name': 'Rose',
      'rgb': [192, 128, 129],
      'opacity': 1.0
    },
    {
      'name': 'PowderBlue',
      'rgb': [176, 224, 230],
      'opacity': 1.0
    },
    {
      'name': 'Wheat',
      'rgb': [245, 222, 179],
      'opacity': 1.0
    },
    {
      'name': 'Pewter',
      'rgb': [137, 148, 153],
      'opacity': 1.0
    },

    // Deep tones (22-29)
    {
      'name': 'Emerald',
      'rgb': [80, 200, 120],
      'opacity': 1.0
    },
    {
      'name': 'Ruby',
      'rgb': [224, 17, 95],
      'opacity': 1.0
    },
    {
      'name': 'Sapphire',
      'rgb': [15, 82, 186],
      'opacity': 1.0
    },
    {
      'name': 'Amethyst',
      'rgb': [153, 102, 204],
      'opacity': 1.0
    },
    {
      'name': 'Forest',
      'rgb': [34, 139, 34],
      'opacity': 1.0
    },
    {
      'name': 'Wine',
      'rgb': [114, 47, 55],
      'opacity': 1.0
    },
    {
      'name': 'Navy',
      'rgb': [0, 0, 128],
      'opacity': 1.0
    },
    {
      'name': 'Charcoal',
      'rgb': [54, 69, 79],
      'opacity': 1.0
    },
  ];

  static List<String> recipeUnits = [
    'g',
    'kg',
    'mg',
    'lb',
    'oz',
    'ml',
    'l',
    'cup',
    'tbsp',
    'tsp',
    'pinch',
  ];

  static Color get backgroundColor => const Color(0xFF2ECC71);
  static Color get backgroundDarkColor => const Color(0xFF186A3B);

  // API endpoints
  static const String apiBaseUrl = 'https://gluttex.com/api';
  static const String fsBaseUrl = 'https://gluttex.com';

  // static const String authApiBaseUrl = 'http://localhost:9090';
  static const String addAppUserEndpoint = '/app_user';
  static const String deleteAppUserEndpoint = '/app_user/delete';
  static const String getAllAppUsersEndpoint = '/app_user';
  static const String appUserEndpoint = '/app_user';
  static const String updateAppUserImageEndpoint = '/app_user/update_image_url';
  static const String updateAppUserEndpoint = '/app_user/update';

  static const String getAppUserCategoriesEndpoint = '/app_user/categorie/all';

  static const String postImageEndpoint = '/fs/upload';

  static const String addProductEndpoint = '/product/add';
  static const String deleteProductEndpoint = '/product/delete';
  static const String getAllProductsEndpoint = '/product';
  static const String productEndpoint = '/product';
  static const String getProductCategoriesEndpoint = '/product/category/all';
  static const String getAllProductsByCategoryEndpoint = '/product/category';
  static const String getProductImageEndpoint = '/image/product';
  static const String getProductFeedEndpoint = '/product/observer';

  static const String addOrderEndpoint = '/business/order/add';
  static const String getAllOrdersEndpoint = '/business/user/orders/all';

  static const String addSupplierEndpoint = '/supplier/add';
  static const String updateSupplierEndpoint = '/supplier';
  static const String getOrganisations = '/org';

  static const String deleteSupplierEndpoint = '/supplier/delete';
  static const String getAllSuppliersEndpoint = '/supplier';
  static const String supplierEndpoint = '/supplier';
  static const String getSupplierCategoriesEndpoint = '/supplier/category/all';
  static const String getRecipeImageEndpoint = '/image/recipe';

  static const String addRecipeEndpoint = '/recipe/add';
  static const String getIngredientEndpoint = '/ingredient';
  static const String deleteRecipeEndpoint = '/recipe/delete';
  static const String getAllRecipesEndpoint = '/recipe';
  static const String recipeEndpoint = '/recipe';
  static const String getRecipeCategoriesEndpoint = '/recipe/category/all';

  static const String loginEndpoint = '/authentication/token';
  static const String signUpEndpoint = '/app_user/add';
  static const String productsEndpoint = '/product';

  static const int adminCategoryId = 3;

  static const int itemsPerPage = 6;

  static const int cookingChefDBId = 3;
  static const int supplierDBId = 4;

  // Texts
  static const String notFoundError = 'Object not found';
  static const String getFailure = 'Failed to load item';
  static const String serverError = 'Failed to connect to the server';

  // Fonts
  static const String defaultFontFamily = 'Roboto';
  static const kTextColor = Color(0xFF535353);
  static const kTextLightColor = Color(0xFFACACAC);

  static const kDefaultPaddin = 20.0;

  Color getCardColor(int index, bool bool, {bool isDarkMode = false}) {
    final clampedIndex = index % _cardColors.length;
    final color = _cardColors[clampedIndex];

    final baseColor = Color.fromRGBO(
      color['rgb'][0] as int,
      color['rgb'][1] as int,
      color['rgb'][2] as int,
      color['opacity'] as double,
    );

    return isDarkMode
        ? baseColor.withOpacity((color['opacity'] as double) * 0.5)
        : baseColor;
  }
}

class GluttexPageIndex {
  static const int catalog = 0;
  static const int suppliers = 1;
  static const int recipes = 2;
  static const int games = 3;
  static const int profile = 4;
}

class AppRoutes {
  static const String login = '/login';
  static const String registration = '/registration';
  static const String home = '/home';
  static const String productDetails = '/product/details';
  static const String supplierDetails = '/supplier/details';
  static const String recipeDetails = '/recipe/details';
  static const String productCreate = '/product/create';
  static const String recipeCreate = '/recipe/create';
  static const String providerCreate = '/provider/create';
  static const String userEdit = '/user/edit';
  static const String imageUpload = '/image/upload';
}
