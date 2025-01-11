import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Gluttex!'**
  String get welcomeMessage;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Gluttex'**
  String get appName;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get errorOccurred;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products to display.'**
  String get noProductsFound;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addToCart;

  /// No description provided for @aboutProvider.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutProvider;

  /// No description provided for @productQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get productQuantity;

  /// No description provided for @productReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get productReference;

  /// No description provided for @priceText.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceText;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get noRecipesFound;

  /// No description provided for @noAppUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noAppUsersFound;

  /// No description provided for @successfullLoginMsg.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed up.'**
  String get successfullLoginMsg;

  /// No description provided for @welcomeBackMsg.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBackMsg;

  /// No description provided for @loginText.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginText;

  /// No description provided for @pleaseLoginMsg.
  ///
  /// In en, this message translates to:
  /// **'Please login to your account'**
  String get pleaseLoginMsg;

  /// No description provided for @pleaseInputUsernameMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseInputUsernameMsg;

  /// No description provided for @pleaseInputPasswordMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseInputPasswordMsg;

  /// No description provided for @passwordLengthConstraintMsg.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthConstraintMsg;

  /// No description provided for @suggestRegistrationMsg.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get suggestRegistrationMsg;

  /// No description provided for @suggest3rdPartyLogintMsg.
  ///
  /// In en, this message translates to:
  /// **'Or login with'**
  String get suggest3rdPartyLogintMsg;

  /// No description provided for @pleaseInputusernameMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseInputusernameMsg;

  /// No description provided for @pleaseInputpasswordMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseInputpasswordMsg;

  /// No description provided for @pleaseInputUserTypeMsg.
  ///
  /// In en, this message translates to:
  /// **'Please select a user type'**
  String get pleaseInputUserTypeMsg;

  /// No description provided for @pleaseInputFirstNameMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a first name'**
  String get pleaseInputFirstNameMsg;

  /// No description provided for @pleaseInputLastNameMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a last name'**
  String get pleaseInputLastNameMsg;

  /// No description provided for @pleaseInputBirthdateMsg.
  ///
  /// In en, this message translates to:
  /// **'Please select your birthdate'**
  String get pleaseInputBirthdateMsg;

  /// No description provided for @pleaseInputLocationNameMsg.
  ///
  /// In en, this message translates to:
  /// **'Please input location name'**
  String get pleaseInputLocationNameMsg;

  /// No description provided for @pleaseInputgenderMsg.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender'**
  String get pleaseInputgenderMsg;

  /// No description provided for @pleaseInputnationalityMsg.
  ///
  /// In en, this message translates to:
  /// **'Please select a nationality'**
  String get pleaseInputnationalityMsg;

  /// No description provided for @pleaseInputBloodTypeMsg.
  ///
  /// In en, this message translates to:
  /// **'Please select a blood type'**
  String get pleaseInputBloodTypeMsg;

  /// No description provided for @pleaseInputCountryMsg.
  ///
  /// In en, this message translates to:
  /// **'Please select a country'**
  String get pleaseInputCountryMsg;

  /// No description provided for @birthdayText.
  ///
  /// In en, this message translates to:
  /// **'Birthdate'**
  String get birthdayText;

  /// No description provided for @loginSuccessfullMsg.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed up.'**
  String get loginSuccessfullMsg;

  /// No description provided for @registerText.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerText;

  /// No description provided for @registerationFormText.
  ///
  /// In en, this message translates to:
  /// **'Registration Form'**
  String get registerationFormText;

  /// No description provided for @usernameText.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameText;

  /// No description provided for @passwordText.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordText;

  /// No description provided for @userTypeText.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userTypeText;

  /// No description provided for @firstNameText.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameText;

  /// No description provided for @lastNameText.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameText;

  /// No description provided for @genderText.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderText;

  /// No description provided for @nationalityText.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationalityText;

  /// No description provided for @bloodTypeText.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodTypeText;

  /// No description provided for @latitudeText.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeText;

  /// No description provided for @longitudeText.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeText;

  /// No description provided for @locationNameText.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get locationNameText;

  /// No description provided for @locationText.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationText;

  /// No description provided for @streetText.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get streetText;

  /// No description provided for @cityText.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityText;

  /// No description provided for @postalCodeText.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCodeText;

  /// No description provided for @countryText.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryText;

  /// No description provided for @clientText.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientText;

  /// No description provided for @cookingChefText.
  ///
  /// In en, this message translates to:
  /// **'Cooking Chef'**
  String get cookingChefText;

  /// No description provided for @genderTextList.
  ///
  /// In en, this message translates to:
  /// **'Male,Female,Other'**
  String get genderTextList;

  /// No description provided for @nationalityTextList.
  ///
  /// In en, this message translates to:
  /// **'Algerian,Other'**
  String get nationalityTextList;

  /// No description provided for @missingText.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get missingText;

  /// No description provided for @productdeletionConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get productdeletionConfirmationMessage;

  /// No description provided for @recipedeletionConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe?'**
  String get recipedeletionConfirmationMessage;

  /// No description provided for @cartAddConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm Add to Cart'**
  String get cartAddConfirmationMessage;

  /// No description provided for @updateProductText.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProductText;

  /// No description provided for @pleaseInputProductNameMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name'**
  String get pleaseInputProductNameMsg;

  /// No description provided for @pleaseInputProductPriceMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product price'**
  String get pleaseInputProductPriceMsg;

  /// No description provided for @pleaseInputProductBrandMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product brand'**
  String get pleaseInputProductBrandMsg;

  /// No description provided for @pleaseInputProductBarcodeMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product bar code'**
  String get pleaseInputProductBarcodeMsg;

  /// No description provided for @pleaseInputvalidnumberMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseInputvalidnumberMsg;

  /// No description provided for @pleaseInputProductDescriptionMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product description'**
  String get pleaseInputProductDescriptionMsg;

  /// No description provided for @pleaseInputProductQuantityMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product quantity'**
  String get pleaseInputProductQuantityMsg;

  /// No description provided for @recipeNameText.
  ///
  /// In en, this message translates to:
  /// **'Recipe Name'**
  String get recipeNameText;

  /// No description provided for @pleaseInputRecipeNameMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a recipe name'**
  String get pleaseInputRecipeNameMsg;

  /// No description provided for @recipeDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Recipe description'**
  String get recipeDescriptionText;

  /// No description provided for @pleaseInputRecipeDescriptionMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a recipe description'**
  String get pleaseInputRecipeDescriptionMsg;

  /// No description provided for @recipeinstructiontext.
  ///
  /// In en, this message translates to:
  /// **'Recipe instructions'**
  String get recipeinstructiontext;

  /// No description provided for @instructionsText.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsText;

  /// No description provided for @numberConstraintMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number between 0 and 999999'**
  String get numberConstraintMsg;

  /// No description provided for @productQuantityText.
  ///
  /// In en, this message translates to:
  /// **'Product Quantity'**
  String get productQuantityText;

  /// No description provided for @productDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get productDescriptionText;

  /// No description provided for @descriptionCharacterConstraintMsg.
  ///
  /// In en, this message translates to:
  /// **'Character limit: 300.'**
  String get descriptionCharacterConstraintMsg;

  /// No description provided for @pickImageMsg.
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pickImageMsg;

  /// No description provided for @submitText.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitText;

  /// No description provided for @productNameTxt.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productNameTxt;

  /// No description provided for @productBrandTxt.
  ///
  /// In en, this message translates to:
  /// **'Product Brand'**
  String get productBrandTxt;

  /// No description provided for @productBarcodeTxt.
  ///
  /// In en, this message translates to:
  /// **'Product Barcode'**
  String get productBarcodeTxt;

  /// No description provided for @productPriceTxt.
  ///
  /// In en, this message translates to:
  /// **'Product Price'**
  String get productPriceTxt;

  /// No description provided for @categoriesNotFoundTxt.
  ///
  /// In en, this message translates to:
  /// **'Categories not found'**
  String get categoriesNotFoundTxt;

  /// No description provided for @noImageSelectedTxt.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelectedTxt;

  /// No description provided for @addProductTxt.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductTxt;

  /// No description provided for @orderNowTxt.
  ///
  /// In en, this message translates to:
  /// **'Order Now'**
  String get orderNowTxt;

  /// No description provided for @subtotalTxt.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotalTxt;

  /// No description provided for @totalTxt.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalTxt;

  /// No description provided for @confirmOrderTxt.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrderTxt;

  /// No description provided for @searchTxt.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTxt;

  /// No description provided for @emptyCartTxt.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty!'**
  String get emptyCartTxt;

  /// No description provided for @taxTxt.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get taxTxt;

  /// No description provided for @discountText.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountText;

  /// No description provided for @cancelTxt.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelTxt;

  /// No description provided for @confirmTxt.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmTxt;

  /// No description provided for @confirmationTxt.
  ///
  /// In en, this message translates to:
  /// **'confirmation'**
  String get confirmationTxt;

  /// No description provided for @addSupplierTxt.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplierTxt;

  /// No description provided for @addBusinessNameMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a business name'**
  String get addBusinessNameMsg;

  /// No description provided for @supplierNameMsg.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get supplierNameMsg;

  /// No description provided for @insertCoordinatesMsg.
  ///
  /// In en, this message translates to:
  /// **'Insert coordinates'**
  String get insertCoordinatesMsg;

  /// No description provided for @addContactInfoMsg.
  ///
  /// In en, this message translates to:
  /// **'Add Contact Info'**
  String get addContactInfoMsg;

  /// No description provided for @contactInfoMsg.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactInfoMsg;

  /// No description provided for @pleaseInputContactInfoMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact info'**
  String get pleaseInputContactInfoMsg;

  /// No description provided for @latitudeMsg.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeMsg;

  /// No description provided for @longitudeMsg.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeMsg;

  /// No description provided for @setLocationMsg.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get setLocationMsg;

  /// No description provided for @updateRecipeMsg.
  ///
  /// In en, this message translates to:
  /// **'Update Recipe'**
  String get updateRecipeMsg;

  /// No description provided for @addIngredientMsg.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredientMsg;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted item'**
  String get deleteSuccess;

  /// No description provided for @putSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully added item'**
  String get putSuccess;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully updated item'**
  String get updateSuccess;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to the server'**
  String get serverError;

  /// No description provided for @notFoundError.
  ///
  /// In en, this message translates to:
  /// **'Object not found'**
  String get notFoundError;

  /// No description provided for @deleteFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete storage item'**
  String get deleteFailure;

  /// No description provided for @getFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to load item'**
  String get getFailure;

  /// No description provided for @putFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to add item'**
  String get putFailure;

  /// No description provided for @updateFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to update item'**
  String get updateFailure;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'{price} DA'**
  String price(Object price);

  /// No description provided for @ingredientSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Ingredient'**
  String get ingredientSelect;

  /// No description provided for @ingredientSearch.
  ///
  /// In en, this message translates to:
  /// **'Search Ingredient'**
  String get ingredientSearch;

  /// No description provided for @ingredientQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter Quantity'**
  String get ingredientQuantity;

  /// No description provided for @addText.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addText;

  /// No description provided for @hoursTextValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String hoursTextValue(Object hours);

  /// No description provided for @minutesTextValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes.'**
  String minutesTextValue(Object minutes);

  /// No description provided for @insertRecipeText.
  ///
  /// In en, this message translates to:
  /// **'Insert Recipe'**
  String get insertRecipeText;

  /// No description provided for @preparationTimeText.
  ///
  /// In en, this message translates to:
  /// **'Preparation Time: {hours} hours, {minutes} minutes'**
  String preparationTimeText(Object hours, Object minutes);

  /// No description provided for @noDescriptionAvailableText.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailableText;

  /// No description provided for @noInstructionsAvailableText.
  ///
  /// In en, this message translates to:
  /// **'No instructions available.'**
  String get noInstructionsAvailableText;

  /// No description provided for @noPreparationTimeText.
  ///
  /// In en, this message translates to:
  /// **'No preparation time available.'**
  String get noPreparationTimeText;

  /// No description provided for @productsText.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsText;

  /// No description provided for @providersText.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get providersText;

  /// No description provided for @recipesText.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesText;

  /// No description provided for @gamesText.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gamesText;

  /// No description provided for @selectLanguageText.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageText;

  /// No description provided for @profileText.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileText;

  /// No description provided for @userInfoText.
  ///
  /// In en, this message translates to:
  /// **'User Informations'**
  String get userInfoText;

  /// No description provided for @personalInfoText.
  ///
  /// In en, this message translates to:
  /// **'Personal Informations'**
  String get personalInfoText;

  /// No description provided for @locationInfoText.
  ///
  /// In en, this message translates to:
  /// **'Location Informations'**
  String get locationInfoText;

  /// No description provided for @orderAmountText.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {amount}'**
  String orderAmountText(Object amount);

  /// No description provided for @productCategoryTextList.
  ///
  /// In en, this message translates to:
  /// **'Baked Goods,Spreads,Cereals,Pasta,Snacks,Beverages,Desserts'**
  String get productCategoryTextList;

  /// No description provided for @allText.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allText;

  /// No description provided for @providerCategoryTextList.
  ///
  /// In en, this message translates to:
  /// **'Restaurant,Bakery,Factory,Supermarket'**
  String get providerCategoryTextList;

  /// No description provided for @recipeCategoryTextList.
  ///
  /// In en, this message translates to:
  /// **'Appetizers & Snacks,Soups & Stews,Salads,Main Courses,Side Dishes,Pasta & Noodles,Casseroles,Breakfast & Brunch,Breads & Baking,Desserts,Drinks & Beverages,Sauces & Condiments,International Cuisine,Healthy & Special Diets,Holiday & Seasonal,Kids & Family,Slow Cooker & Instant Pot,Quick & Easy,One-Pan Recipes,Grilling & BBQ'**
  String get recipeCategoryTextList;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
