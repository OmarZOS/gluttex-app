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

  static List<String> productUnits = [
    'g',
    'kg',
    'mg',
    'L',
    'mL',
    'pc',
    'pkg',
    'box',
    'bag',
    'slice',
    'cup',
  ];

  static Color get backgroundColor => const Color(0xFF2ECC71);
  static Color get backgroundDarkColor => const Color(0xFF186A3B);

  static const String apiBaseUrl = 'http://localhost:9000/api/v1';
  static const String fsBaseUrl = 'http://localhost:9000/fs';

  static const String postImageEndpoint = '/fs/upload';

  // ==================== Authentication Endpoints ====================
  static const String loginEndpoint = '/authentication/token';
  static const String logoutEndpoint = '/logout';
  static const String oauthLoginEndpoint = '/login'; // /login/{provider}
  static const String oauthCallbackEndpoint = '/auth'; // /auth/{provider}
  static const String signUpEndpoint = '/app_user';

  // ==================== User/AppUser Endpoints ====================
  static const String getAppUserCategoriesEndpoint = '/app_user/categorie/all';
  static const String addAppUserEndpoint = '/app_user';
  static const String deleteAppUserEndpoint = '/app_user';
  static const String getAllAppUsersEndpoint = '/app_user';
  static const String appUserEndpoint = '/app_user';
  static const String updateAppUserImageEndpoint = '/app_user/update_image_url';
  static const String updateAppUserEndpoint = '/app_user/update';
  static const String updateAppUserPasswordEndpoint =
      '/app_user/update_password';
  static const String searchAppUserEndpoint = '/app_user/search';
  static const String getUserByEmailEndpoint = '/app_user/by-email';

  // ==================== Person Endpoints ====================
  static const String personEndpoint = '/person';
  static const String createOrUpdatePersonEndpoint = '/'; // POST /api/v1/
  static const String getAllPersonsEndpoint = '/'; // GET /api/v1/
  static const String searchPersonsByNameEndpoint = '/search/name';
  static const String getAllBloodTypesEndpoint = '/blood-types/all';
  static const String getBloodTypeEndpoint = '/blood-type';

  // ==================== Staff/Management Rule Endpoints ====================
  static const String addRuleEndpoint = '/staff';
  static const String getStaffEndpoint = '/staff';
  static const String updateStaffEndpoint = '/staff';
  static const String deleteStaffEndpoint = '/staff/delete';
  static const String answerStaffInvitationEndpoint = '/staff/answer';
  static const String getUserStaffEndpoint = '/staff/user';
  static const String getProviderStaffEndpoint = '/staff/provider';
  static const String getPendingInvitationsEndpoint = '/staff/pending';

  // ==================== Notification Endpoints ====================
  static const String getNotificationsEndpoint = '/notifications';
  static const String createNotificationEndpoint = '/create';
  static const String notificationEndpoint = '/'; // /{notification_id}
  static const String readNotificationEndpoint =
      '/read'; // /{notification_id}/read
  static const String userNotificationsEndpoint = '/user'; // /user/{user_ref}
  static const String userReadAllEndpoint =
      '/read-all'; // /user/{user_ref}/read-all
  static const String userAllEndpoint = '/all'; // /user/{user_ref}/all
  static const String userUnreadCountEndpoint =
      '/unread-count'; // /user/{user_ref}/unread-count
  static const String sendInvitationEndpoint = '/invitation/send';
  static const String bulkCreateNotificationsEndpoint = '/bulk/create';

  // ==================== Product Endpoints ====================
  static const String addProductEndpoint = '/products';
  static const String deleteProductEndpoint = '/products/delete';
  static const String getAllProductsEndpoint = '/products';
  static const String productEndpoint = '/products';
  static const String updateProductEndpoint =
      '/products'; // /products/{product_id}
  static const String getProductCategoriesEndpoint = '/products/category/all';
  static const String getAllProductsByCategoryEndpoint = '/products/category';
  static const String getProductImageEndpoint = '/products/image';
  static const String getProductFeedEndpoint = '/products/observer';
  static const String getProductSearchByBarcodeEndpoint = '/products/barcode';
  static const String getProductDBSearchByBarcodeEndpoint =
      '/products/db/barcode';
  static const String getProductSearchByImageEndpoint =
      '/products/search/image';
  static const String getProductByIdEndpoint =
      '/products'; // /products/{product_id}

  // ==================== Recipe Endpoints ====================
  static const String addRecipeEndpoint = '/recipes';
  static const String deleteRecipeEndpoint = '/recipes';
  static const String getAllRecipesEndpoint = '/recipes';
  static const String recipeEndpoint = '/recipes';
  static const String updateRecipeEndpoint = '/recipes'; // /recipes/{recipe_id}
  static const String getRecipeCategoriesEndpoint = '/recipes/categories';
  static const String getRecipeImageEndpoint =
      '/recipes/image'; // Adjust based on your API
  static const String getRecipeSearchByTokenEndpoint =
      '/recipes/search'; // Adjust
  static const String getAllIngredientEndpoint = '/recipes/ingredients/all';
  static const String deleteIngredientEndpoint = '/recipes/ingredients';
  static const String getIngredientEndpoint = "/recipes/ingredients";
  static const String addIngredientEndpoint = "/recipes/ingredients";
  static const String updateIngredientEndpoint = "/recipes/ingredients";

  // ==================== Supplier Endpoints ====================
  static const String addSupplierEndpoint = '/suppliers';
  static const String updateSupplierEndpoint = '/suppliers';
  static const String deleteSupplierEndpoint = '/suppliers';
  static const String getAllSuppliersEndpoint = '/suppliers';
  static const String supplierEndpoint = '/suppliers';
  static const String getSupplierCategoriesEndpoint = '/supplier-types';
  static const String getSupplierSearchByTokenEndpoint =
      '/suppliers/search'; // Adjust
  static const String getSupplierSearchByGeoEndpoint =
      '/suppliers/search/location';
  static const String getSupplierByIdEndpoint =
      '/suppliers'; // /suppliers/{provider_id}

  // ==================== Organisation Endpoints ====================
  static const String getOrganisationsEndpoint = '/organisations';
  static const String createOrganisationEndpoint = '/organisations';
  static const String updateOrganisationEndpoint = '/organisations';
  static const String deleteOrganisationEndpoint = '/organisations';
  static const String getOrganisationByIdEndpoint = '/organisations';

  // ==================== Order Endpoints ====================
  static const String addOrderEndpoint = '/business/orders';
  static const String getAllOrdersEndpoint = '/business/orders/user';
  static const String getOrderDetailsEndpoint = '/business/orders';
  static const String updateOrderEndpoint = '/business/orders';
  static const String deleteOrderEndpoint = '/business/orders';
  static const String updateOrderStatusEndpoint = '/business/orders/status';
  static const String getOrderItemsEndpoint = '/business/orders/items';

  // ==================== Cart Endpoints ====================
  static const String getCartsEndpoint = '/business/carts';
  static const String cartEndpoint = '/business/carts';
  static const String postCartEndpoint = '/business/carts';
  static const String getCartDetailsEndpoint = '/business/carts';
  static const String deleteCartEndpoint = '/business/carts';
  static const String updateCartStatusEndpoint = '/business/carts/status';
  static const String getCartItemsEndpoint = '/business/carts/items';
  static const String getCartServicesEndpoint = '/business/carts/services';
  static const String getCartSummaryEndpoint = '/business/carts/summary';

  // ==================== Delivery Endpoints ====================
  static const String addDeliveryEndpoint = '/business/deliveries';
  static const String getAllDeliveriesEndpoint = '/business/deliveries';
  static const String getDeliveryDetailsEndpoint = '/business/deliveries';
  static const String updateDeliveryEndpoint = '/business/deliveries';
  static const String deleteDeliveryEndpoint = '/business/deliveries';
  static const String updateDeliveryStatusEndpoint =
      '/business/deliveries/status';
  static const String updateDeliveryAddressEndpoint =
      '/business/deliveries/address';
  static const String updateDeliveryTrackingEndpoint =
      '/business/deliveries/tracking';
  static const String getDeliveriesByStatusEndpoint =
      '/business/deliveries/status';
  static const String bulkDeleteDeliveriesEndpoint =
      '/business/deliveries/bulk/delete';
  static const String bulkUpdateDeliveryStatusEndpoint =
      '/business/deliveries/bulk/update-status';
  static const String getDeliveryStatsEndpoint = '/business/deliveries/stats';

  // ==================== Service Endpoints ====================
  static const String addServiceEndpoint = '/business/services';
  static const String deleteServiceEndpoint = '/business/services';
  static const String serviceEndpoint = '/business/services';
  static const String updateServiceEndpoint = '/business/services';
  static const String getServicesByCategoryEndpoint =
      '/business/services/category';
  static const String getServicesByProviderEndpoint =
      '/business/services/provider';
  static const String toggleServiceStatusEndpoint = '/business/services/toggle';
  static const String getServiceRequirementsEndpoint =
      '/business/services/requirements';
  static const String getServiceStaffRequirementsEndpoint =
      '/business/services/staff-requirements';

  // ==================== Financial Endpoints ====================
  static const String postPaymentEndpoint = '/business/payments';
  static const String getPaymentsEndpoint = '/business/payments';
  static const String getPaymentByIdEndpoint = '/business/payments';
  static const String createDepositEndpoint = '/business/deposits';
  static const String getDepositsEndpoint = '/business/deposits';
  static const String getDepositByIdEndpoint = '/business/deposits';
  static const String createFeeEndpoint = '/business/fees';
  static const String getFeesEndpoint = '/business/fees';
  static const String getFeeByIdEndpoint = '/business/fees';
  static const String getFinancialDocsEndpoint = '/business/finance'; // Adjust

  // ==================== Business Operations Endpoints ====================
  static const String getBusinessOperationsEndpoint = '/business/operations';

  // ==================== Health/Medical Endpoints ====================
  static const String getSerologyHistoryEndpoint = '/patient/serology/history';
  static const String getSerologyIndicatorsEndpoint = '/serology/indicators';
  static const String getSerologyIndicatorEndpoint = '/serology/indicator';
  static const String getSerologyRecordEndpoint = '/serology';
  static const String addSerologyRecordEndpoint = '/patient/serology';
  static const String updateSerologyRecordEndpoint = '/patient/serology/update';
  static const String deleteSerologyRecordEndpoint = '/patient/serology/delete';
  static const String getAllSymptomsEndpoint = '/symptoms/all';
  static const String getSymptomEndpoint = '/symptoms';
  static const String addSymptomOccurrenceEndpoint = '/patient/symptoms';
  static const String getSymptomHistoryEndpoint = '/patient/symptoms/history';
  static const String getSymptomOccurrenceEndpoint =
      '/patient/symptoms/occurrence';
  static const String deleteSymptomOccurrenceEndpoint =
      '/patient/symptoms/delete';

  // ==================== Reaction Endpoints ====================
  static const String reactionEndpoint = '/reaction';

  // ==================== Search Endpoints ====================
  static const String productSearchEndpoint = '/products/search';
  static const String recipeSearchEndpoint = '/recipes/search';
  static const String supplierSearchEndpoint = '/suppliers/search';
  static const String multiSearchEndpoint = '/search/multi';
  static const String quickSearchEndpoint = '/search/quick';

  // ==================== Document Endpoints ====================
  static const String cartInvoiceEndpoint = '/cart/invoice';
  static const String cartReceiptEndpoint = '/cart/receipt';
  static const String cartInvoicePdfEndpoint = '/cart/invoice/pdf';
  static const String cartReceiptPdfEndpoint = '/cart/receipt/pdf';
  static const String cartDataEndpoint = '/cart/data';

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

class ProductAssistedFields {
  static const String IPRODUCT_NAME = "iproduct_name";
  static const String IPRODUCT_BRAND = "iproduct_brand";
  static const String IPRODUCT_BARCODE = "iproduct_barcode";
  static const String IPRODUCT_ESTIMATED_PRICE_DA =
      "iproduct_estimated_price_DA";
  static const String IPRODUCT_GLUTEN_STATUS = "iproduct_gluten_status";
  static const String DESCRIPTION = "iproduct_desc";
  static const String QUANTIFIER = "iproduct_quantifier";
  static const String QUANTITY = "iproduct_quantity";
}

class OrderStates {
  static const String COMPLETED_ORDER_STATE = "COMPLETED";
  static const String DELIVERED_ORDER_STATE = "DELIVERED";
  static const String PENDING_ORDER_STATE = "PENDING";
  static const String CANCELLED_ORDER_STATE = "CANCELLED";
  static const String PROCESSING_ORDER_STATE = "PROCESSING";
}

class AppRoutes {
  static const String login = '/login';
  static const String registration = '/registration';
  static const String home = '/home';
  static const String productDetails = '/product/details';
  static const String supplierDetails = '/suppliers/details';
  static const String recipeDetails = '/recipe/details';
  static const String productCreate = '/product/create';
  static const String recipeCreate = '/recipe/create';
  static const String providerCreate = '/provider/create';
  static const String userEdit = '/user/edit';
  static const String imageUpload = '/image/upload';
  static const String cartPage = '/cart';
  static const String ordersPage = '/orders';
  static const String productScanPage = '/product/scan';
  static const String QRScanPage = '/qr/scan';
  static const String productCapturePage = '/product/capture';

  static const String ingredientManagement = '/ingredient/management';

  static const String supplierEntitiesPage = '/suppliers/entities';
  static const String dashboardPage = '/dashboard/business';

  static const String productCatalog = '/productCatalog';
  static const String suppliersMap = '/suppliersMap';
  static const String recipeCatalog = '/recipeCatalog';
  static const String games = '/games';
  static const String profile = '/profile';
  static const String supplierManage = '/manage';
  static const String storeManage = '/store';
  static const String serviceForm = '/service/form';
}

class RuleStates {
  static const String pending = 'PENDING';
  static const String rejected = 'REJECTED';
  static const String suspended = 'SUSPENDED';
  static const String obsolete = 'OBSOLETE';
  static const String active = 'ACTIVE';
}

class RoleTypes {
  static const String inventory_view = 'inventory_view';
  static const String inventory_manage = 'inventory_manage';
  static const String orders_view = 'orders_view';
  static const String orders_manage = 'orders_manage';
  static const String personnel_view = 'personnel_view';
  static const String personnel_manage = 'personnel_manage';
}
