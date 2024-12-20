library gluttex_constants;

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class GluttexConstants {
  // API endpoints
  static const String apiBaseUrl = 'http://192.168.162.158:9000';
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
  // // Login:
  static const String successfullLoginMsg = "Successfully signed up.";
  static const String welcomeBackMsg = 'Welcome Back!';
  static const String loginText = 'Login';
  static const String pleaseLoginMsg = 'Please login to your account';
  static const String pleaseInputUsernameMsg = 'Please enter your username';
  static const String pleaseInputPasswordMsg = 'Please enter your password';
  static const String passwordLengthConstraintMsg =
      'Password must be at least 6 characters';
  static const String suggestRegistrationMsg =
      'Don\'t have an account? Register';
  static const String suggest3rdPartyLogintMsg = 'Or login with';
  // // Registration:
  static const String pleaseInputusernameMsg = 'Please enter a username';
  static const String pleaseInputpasswordMsg = 'Please enter a password';
  static const String pleaseInputUserTypeMsg = 'Please select a user type';
  static const String pleaseInputFirstNameMsg = 'Please enter a first name';
  static const String pleaseInputLastNameMsg = 'Please enter a last name';
  static const String pleaseInputBirthdateMsg = 'Please select your birthdate';
  static const String pleaseInputLocationNameMsg = 'Please input location name';
  static const String pleaseInputgenderMsg = 'Please select a gender';
  static const String pleaseInputnationalityMsg = 'Please select a nationality';
  static const String pleaseInputBloodTypeMsg = 'Please select a blood type';
  static const String pleaseInputCountryMsg = 'Please select a country';
  static const String birthdayText = 'Birthdate';
  static const String loginSuccessfullMsg = "Successfully signed up.";
  static const String registerText = 'Register';
  static const String registerationFormText = 'Registration Form';

  static const String usernameText = 'Username';
  static const String passwordText = 'Password';
  static const String userTypeText = 'User Type';
  static const String firstNameText = 'First Name';
  static const String lastNameText = 'Last Name';
  static const String genderText = 'Gender';
  static const String nationalityText = 'Nationality';
  static const String bloodTypeText = 'Blood Type';
  static const String latitudeText = 'Latitude';
  static const String longitudeText = 'Longitude';
  static const String locationNameText = 'Location Name';
  static const String locationText = 'Location';
  static const String streetText = 'Street';
  static const String cityText = 'City';
  static const String postalCodeText = 'Postal Code';
  static const String countryText = 'Country';
  static const String clientText = 'Client';
  static const String cookingChefText = 'Cooking Chef';
  static const List<String> genderTextList = ['Male', 'Female', 'Other'];
  static const List<String> nationalityTextList = ['Algerian', 'Other'];
  // // Product
  static const String missingText = 'Missing';
  static const String productdeletionConfirmationMessage =
      'Are you sure you want to delete this product?';
  static const String cartAddConfirmationMessage = "Confirm Add to Cart";
  static const String updateProductText = 'Update Product';

  static const String pleaseInputProductNameMsg = 'Please enter a product name';
  static const String pleaseInputProductPriceMsg =
      'Please enter a product price';
  static const String pleaseInputProductBrandMsg =
      'Please enter a product brand';
  static const String pleaseInputProductBarcodeMsg =
      'Please enter a product bar code';
  static const String pleaseInputvalidnumberMsg = 'Please enter a valid number';
  static const String numberConstraintMsg =
      'Please enter a number between 0 and 999999';
  static const String pleaseInputProductDescriptionMsg =
      'Please enter a product description';
  static const String pleaseInputProductQuantityMsg =
      'Please enter a product quantity';
  static const String ProductQuantityText = 'Product Quantity';
  static const String ProductDescriptionText = 'Product Description';
  static const String descriptionCharacterConstraintMsg =
      'Character limit: 300.';
  static const String pickImageMsg = 'Pick Image';
  static const String submitText = 'Submit';
  static const String productNameTxt = 'Product Name';
  static const String productBrandTxt = 'Product Brand';
  static const String productBarcodeTxt = 'Product Barcode';
  static const String productPriceTxt = 'Product Price';
  static const String categoriesNotFoundTxt = 'Categories not found';
  static const String noImageSelectedTxt = 'No image selected';
  static const String addProductTxt = 'Add Product';
  static const String orderNowTxt = 'Order Now';
  static const String subtotalTxt = 'Subtotal';
  static const String totalTxt = 'Total';
  static const String confirmOrderTxt = "Confirm Order";
  static const String searchTxt = 'Search';
  static const String emptyCartTxt = 'Your cart is empty!';

  static const String taxTxt = 'Tax';
  static const String discountText = 'Discount';
  static const String cancelTxt = 'Cancel';
  static const String confirmTxt = 'Confirm';
  static const String confirmationTxt = 'confirmation';
  static const String addSupplierTxt = 'Add Supplier';
  static const String addBusinessNameMsg = 'Please enter a business name';
  static const String supplierNameMsg = 'Supplier Name';
  static const String insertCoordinatesMsg = 'Insert coordinates';
  static const String addContactInfoMsg = 'Add Contact Info';
  static const String contactInfoMsg = 'Contact information';
  static const String pleaseInputContactInfoMsg = 'Please enter contact info';
  static const String latitudeMsg = 'Latitude';
  static const String longitudeMsg = 'Longitude';
  static const String setLocationMsg = 'Set Location';
  static const String updateRecipeMsg = 'Update Recipe';
  static const String addIngredientMsg = 'Add Ingredient';

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
