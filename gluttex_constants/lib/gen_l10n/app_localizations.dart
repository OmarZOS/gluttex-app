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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @myLocationText.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocationText;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @mapNotAvailableText.
  ///
  /// In en, this message translates to:
  /// **'Map actually not available on this device'**
  String get mapNotAvailableText;

  /// No description provided for @pdfNotSupportedOnWeb.
  ///
  /// In en, this message translates to:
  /// **'PDF files are not supported on web. Please use a mobile device.'**
  String get pdfNotSupportedOnWeb;

  /// No description provided for @registrationConditionsText.
  ///
  /// In en, this message translates to:
  /// **'Conditions of registration'**
  String get registrationConditionsText;

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
  /// **'Baked Goods,Spreads,Cereals,Pasta,Snacks,Beverages,Desserts,Frozen Foods,Baking Ingredients,Packaged Goods'**
  String get productCategoryTextList;

  /// No description provided for @allText.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allText;

  /// No description provided for @providerCategoryTextList.
  ///
  /// In en, this message translates to:
  /// **'Restaurant,Bakery,Factory,Supermarket,Grocery Store,Distributor'**
  String get providerCategoryTextList;

  /// No description provided for @recipeCategoryTextList.
  ///
  /// In en, this message translates to:
  /// **'Appetizers & Snacks,Soups & Stews,Salads,Main Courses,Side Dishes,Pasta & Noodles,Casseroles,Breakfast & Brunch,Breads & Baking,Desserts,Drinks & Beverages,Sauces & Condiments,International Cuisine,Healthy & Special Diets,Holiday & Seasonal,Kids & Family,Slow Cooker & Instant Pot,Quick & Easy,One-Pan Recipes,Grilling & BBQ'**
  String get recipeCategoryTextList;

  /// No description provided for @ingredientTextList.
  ///
  /// In en, this message translates to:
  /// **'Wheat,Barley ,Rye,Oats ,Corn ,Rice ,Soy,Milk ,Egg,Peanuts,Tree Nuts,Fish ,Shellfish,Lentils,Chickpeas,Buckwheat,Almond ,Coconut,Sunflower Seeds,Pumpkin Seeds,Sesame Seeds ,Potato ,Sweet Potato ,Gelatin,Lupin,Mustard,Fennel ,Cumin,Ginger ,Garlic ,Onion,Leek ,Shallot,Scallion ,Chive,Parsley,Cilantro ,Basil,Oregano,Thyme,Rosemary ,Sage ,Mint ,Lemongrass ,Lavender ,Paprika,Chili Pepper ,Black Pepper ,White Pepper ,Green Pepper ,Red Pepper ,Cinnamon ,Allspice ,Butter ,Margarine,Vegetable Oil,Baking Powder,Baking Soda,Cornstarch ,All-Purpose Flour,Pastry Flour ,Self-Rising Flour'**
  String get ingredientTextList;

  /// No description provided for @cartText.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartText;

  /// No description provided for @ordersText.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersText;

  /// No description provided for @noOrdersTxt.
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get noOrdersTxt;

  /// No description provided for @orderIdentifierTxt.
  ///
  /// In en, this message translates to:
  /// **'Identifier: {orderId}'**
  String orderIdentifierTxt(Object orderId);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageText.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageText;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current language: {currentLang}'**
  String currentLanguage(Object currentLang);

  /// No description provided for @darkModeText.
  ///
  /// In en, this message translates to:
  /// **'Toggle dark mode'**
  String get darkModeText;

  /// No description provided for @profileUpdateText.
  ///
  /// In en, this message translates to:
  /// **'Update profile informations'**
  String get profileUpdateText;

  /// No description provided for @passwordUpdateText.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get passwordUpdateText;

  /// No description provided for @showMoreText.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMoreText;

  /// No description provided for @question_1.
  ///
  /// In en, this message translates to:
  /// **'Which traditional dish is naturally gluten-free?'**
  String get question_1;

  /// No description provided for @options_1.
  ///
  /// In en, this message translates to:
  /// **'Pizza,Tamales,Lasagna,Croissants'**
  String get options_1;

  /// No description provided for @question_2.
  ///
  /// In en, this message translates to:
  /// **'Which grain contains gluten?'**
  String get question_2;

  /// No description provided for @options_2.
  ///
  /// In en, this message translates to:
  /// **'Rice,Quinoa,Wheat,Corn'**
  String get options_2;

  /// No description provided for @question_3.
  ///
  /// In en, this message translates to:
  /// **'What is Celiac Disease?'**
  String get question_3;

  /// No description provided for @options_3.
  ///
  /// In en, this message translates to:
  /// **'A gluten allergy,An autoimmune disorder,A viral infection,A type of flu'**
  String get options_3;

  /// No description provided for @question_4.
  ///
  /// In en, this message translates to:
  /// **'Which of these is safe for a gluten-free diet?'**
  String get question_4;

  /// No description provided for @options_4.
  ///
  /// In en, this message translates to:
  /// **'Barley,Rye,Oats (certified GF),Wheat'**
  String get options_4;

  /// No description provided for @question_5.
  ///
  /// In en, this message translates to:
  /// **'What does gluten do in baking?'**
  String get question_5;

  /// No description provided for @options_5.
  ///
  /// In en, this message translates to:
  /// **'Adds sweetness,Gives elasticity,Increases moisture,Reduces calories'**
  String get options_5;

  /// No description provided for @question_6.
  ///
  /// In en, this message translates to:
  /// **'Which of these is naturally gluten-free?'**
  String get question_6;

  /// No description provided for @options_6.
  ///
  /// In en, this message translates to:
  /// **'Spelt,Soy sauce,Buckwheat,Couscous'**
  String get options_6;

  /// No description provided for @question_7.
  ///
  /// In en, this message translates to:
  /// **'What is a common gluten-free flour?'**
  String get question_7;

  /// No description provided for @options_7.
  ///
  /// In en, this message translates to:
  /// **'Almond flour,Rye flour,Spelt flour,Durum wheat'**
  String get options_7;

  /// No description provided for @question_8.
  ///
  /// In en, this message translates to:
  /// **'Which type of pasta is gluten-free?'**
  String get question_8;

  /// No description provided for @options_8.
  ///
  /// In en, this message translates to:
  /// **'Whole wheat pasta,Egg noodles,Rice noodles,Semolina pasta'**
  String get options_8;

  /// No description provided for @question_9.
  ///
  /// In en, this message translates to:
  /// **'Which beer is safe for a gluten-free diet?'**
  String get question_9;

  /// No description provided for @options_9.
  ///
  /// In en, this message translates to:
  /// **'Wheat beer,Barley malt beer,Rice-based beer,Lager beer'**
  String get options_9;

  /// No description provided for @question_10.
  ///
  /// In en, this message translates to:
  /// **'Which of these ingredients should be avoided in a GF diet?'**
  String get question_10;

  /// No description provided for @options_10.
  ///
  /// In en, this message translates to:
  /// **'Xanthan gum,Malt extract,Tapioca starch,Corn flour'**
  String get options_10;

  /// No description provided for @question_11.
  ///
  /// In en, this message translates to:
  /// **'What does \'certified gluten-free\' mean?'**
  String get question_11;

  /// No description provided for @options_11.
  ///
  /// In en, this message translates to:
  /// **'Contains some wheat,Has less than 20 ppm gluten,Made with whole grains,Labeled for celiacs'**
  String get options_11;

  /// No description provided for @question_12.
  ///
  /// In en, this message translates to:
  /// **'What is cross-contamination?'**
  String get question_12;

  /// No description provided for @options_12.
  ///
  /// In en, this message translates to:
  /// **'Mixing food colors,Unintentional gluten exposure,Overcooking food,Adding spices'**
  String get options_12;

  /// No description provided for @question_13.
  ///
  /// In en, this message translates to:
  /// **'Which food requires a gluten-free label to be safe?'**
  String get question_13;

  /// No description provided for @options_13.
  ///
  /// In en, this message translates to:
  /// **'Apple,Fresh fish,Flavored yogurt,White rice'**
  String get options_13;

  /// No description provided for @question_14.
  ///
  /// In en, this message translates to:
  /// **'What part of wheat contains gluten?'**
  String get question_14;

  /// No description provided for @options_14.
  ///
  /// In en, this message translates to:
  /// **'Bran,Germ,Endosperm,All of the above'**
  String get options_14;

  /// No description provided for @question_15.
  ///
  /// In en, this message translates to:
  /// **'Which of these grains contains gluten?'**
  String get question_15;

  /// No description provided for @options_15.
  ///
  /// In en, this message translates to:
  /// **'Sorghum,Millet,Kamut,Teff'**
  String get options_15;

  /// No description provided for @question_16.
  ///
  /// In en, this message translates to:
  /// **'Gluten can be found in:'**
  String get question_16;

  /// No description provided for @options_16.
  ///
  /// In en, this message translates to:
  /// **'Rice,Soy sauce,Buckwheat,Quinoa'**
  String get options_16;

  /// No description provided for @question_17.
  ///
  /// In en, this message translates to:
  /// **'Which of these is a gluten-free thickener?'**
  String get question_17;

  /// No description provided for @options_17.
  ///
  /// In en, this message translates to:
  /// **'Flour,Cornstarch,Roux,Wheat starch'**
  String get options_17;

  /// No description provided for @question_18.
  ///
  /// In en, this message translates to:
  /// **'Which of these is NOT a symptom of gluten intolerance?'**
  String get question_18;

  /// No description provided for @options_18.
  ///
  /// In en, this message translates to:
  /// **'Headaches,Joint pain,Improved digestion,Fatigue'**
  String get options_18;

  /// No description provided for @question_19.
  ///
  /// In en, this message translates to:
  /// **'Which country has the highest awareness of gluten-free diets?'**
  String get question_19;

  /// No description provided for @options_19.
  ///
  /// In en, this message translates to:
  /// **'USA,Italy,Japan,India'**
  String get options_19;

  /// No description provided for @question_20.
  ///
  /// In en, this message translates to:
  /// **'Which of these brands offers gluten-free products?'**
  String get question_20;

  /// No description provided for @options_20.
  ///
  /// In en, this message translates to:
  /// **'Kellogg’s,Udi’s,Nestlé,Oreo'**
  String get options_20;

  /// No description provided for @question_21.
  ///
  /// In en, this message translates to:
  /// **'Is popcorn gluten-free?'**
  String get question_21;

  /// No description provided for @options_21.
  ///
  /// In en, this message translates to:
  /// **'Yes,No,Only air-popped,Only flavored ones'**
  String get options_21;

  /// No description provided for @question_22.
  ///
  /// In en, this message translates to:
  /// **'Which fast food chain has gluten-free options?'**
  String get question_22;

  /// No description provided for @options_22.
  ///
  /// In en, this message translates to:
  /// **'McDonald\'s,Chipotle,KFC,Domino’s'**
  String get options_22;

  /// No description provided for @question_23.
  ///
  /// In en, this message translates to:
  /// **'What is cross-contamination?'**
  String get question_23;

  /// No description provided for @options_23.
  ///
  /// In en, this message translates to:
  /// **'Cooking with GF ingredients,When gluten touches GF food,Certified gluten-free process,A type of wheat'**
  String get options_23;

  /// No description provided for @question_24.
  ///
  /// In en, this message translates to:
  /// **'Which of these breakfast cereals is GF?'**
  String get question_24;

  /// No description provided for @options_24.
  ///
  /// In en, this message translates to:
  /// **'Corn Flakes,Rice Krispies,Chex (Rice),Weetabix'**
  String get options_24;

  /// No description provided for @question_25.
  ///
  /// In en, this message translates to:
  /// **'Which of these chocolates is gluten-free?'**
  String get question_25;

  /// No description provided for @options_25.
  ///
  /// In en, this message translates to:
  /// **'Twix,Snickers,KitKat,Oreos'**
  String get options_25;

  /// No description provided for @question_26.
  ///
  /// In en, this message translates to:
  /// **'Which of these contains gluten?'**
  String get question_26;

  /// No description provided for @options_26.
  ///
  /// In en, this message translates to:
  /// **'Soy sauce,Coconut flour,Almond flour,Chia seeds'**
  String get options_26;

  /// No description provided for @question_27.
  ///
  /// In en, this message translates to:
  /// **'What is a GF alternative to breadcrumbs?'**
  String get question_27;

  /// No description provided for @options_27.
  ///
  /// In en, this message translates to:
  /// **'Oat flour,Rice flour,Crushed nuts,All-purpose flour'**
  String get options_27;

  /// No description provided for @question_28.
  ///
  /// In en, this message translates to:
  /// **'Which of these is a symptom of Celiac Disease?'**
  String get question_28;

  /// No description provided for @options_28.
  ///
  /// In en, this message translates to:
  /// **'Rashes,Weight gain,Increased appetite,Lower immunity'**
  String get options_28;

  /// No description provided for @question_29.
  ///
  /// In en, this message translates to:
  /// **'Which of these snacks is GF?'**
  String get question_29;

  /// No description provided for @options_29.
  ///
  /// In en, this message translates to:
  /// **'Pretzels,Chips (corn-based),Granola bars,Ritz crackers'**
  String get options_29;

  /// No description provided for @question_30.
  ///
  /// In en, this message translates to:
  /// **'Which famous athlete promotes a GF diet?'**
  String get question_30;

  /// No description provided for @options_30.
  ///
  /// In en, this message translates to:
  /// **'Serena Williams,Tom Brady,LeBron James,Cristiano Ronaldo'**
  String get options_30;

  /// No description provided for @question_31.
  ///
  /// In en, this message translates to:
  /// **'What kind of pizza crust is GF?'**
  String get question_31;

  /// No description provided for @options_31.
  ///
  /// In en, this message translates to:
  /// **'Whole wheat,Cauliflower,Sourdough,Focaccia'**
  String get options_31;

  /// No description provided for @question_32.
  ///
  /// In en, this message translates to:
  /// **'Which pasta alternative is GF?'**
  String get question_32;

  /// No description provided for @options_32.
  ///
  /// In en, this message translates to:
  /// **'Whole wheat pasta,Chickpea pasta,Semolina pasta,Egg noodles'**
  String get options_32;

  /// No description provided for @question_33.
  ///
  /// In en, this message translates to:
  /// **'Which of these condiments contains gluten?'**
  String get question_33;

  /// No description provided for @options_33.
  ///
  /// In en, this message translates to:
  /// **'Ketchup,Mustard,Teriyaki sauce,Mayonnaise'**
  String get options_33;

  /// No description provided for @question_34.
  ///
  /// In en, this message translates to:
  /// **'Is quinoa gluten-free?'**
  String get question_34;

  /// No description provided for @options_34.
  ///
  /// In en, this message translates to:
  /// **'Yes,No,Only organic quinoa,Only in small amounts'**
  String get options_34;

  /// No description provided for @question_35.
  ///
  /// In en, this message translates to:
  /// **'What is the main ingredient in GF bread?'**
  String get question_35;

  /// No description provided for @options_35.
  ///
  /// In en, this message translates to:
  /// **'Almond flour,Wheat flour,Corn starch,Oats'**
  String get options_35;

  /// No description provided for @question_36.
  ///
  /// In en, this message translates to:
  /// **'Which grains are naturally GF?'**
  String get question_36;

  /// No description provided for @options_36.
  ///
  /// In en, this message translates to:
  /// **'Rye,Barley,Amaranth,Spelt'**
  String get options_36;

  /// No description provided for @question_37.
  ///
  /// In en, this message translates to:
  /// **'Which soup ingredient might contain gluten?'**
  String get question_37;

  /// No description provided for @options_37.
  ///
  /// In en, this message translates to:
  /// **'Chicken broth,Rice noodles,Vegetable stock,Soy milk'**
  String get options_37;

  /// No description provided for @question_38.
  ///
  /// In en, this message translates to:
  /// **'Which of these vitamins may be low in a GF diet?'**
  String get question_38;

  /// No description provided for @options_38.
  ///
  /// In en, this message translates to:
  /// **'Vitamin C,Vitamin D,Iron,Omega-3'**
  String get options_38;

  /// No description provided for @question_39.
  ///
  /// In en, this message translates to:
  /// **'Can gluten be found in medicines?'**
  String get question_39;

  /// No description provided for @options_39.
  ///
  /// In en, this message translates to:
  /// **'Yes,No,Only in vaccines,Only in liquid medicine'**
  String get options_39;

  /// No description provided for @question_40.
  ///
  /// In en, this message translates to:
  /// **'Which flour alternative is highest in protein?'**
  String get question_40;

  /// No description provided for @options_40.
  ///
  /// In en, this message translates to:
  /// **'Corn flour,Tapioca flour,Chickpea flour,Rice flour'**
  String get options_40;

  /// No description provided for @question_41.
  ///
  /// In en, this message translates to:
  /// **'Which of these is a safe thickener for GF sauces?'**
  String get question_41;

  /// No description provided for @options_41.
  ///
  /// In en, this message translates to:
  /// **'Wheat flour,Cornstarch,Roux,All-purpose flour'**
  String get options_41;

  /// No description provided for @question_42.
  ///
  /// In en, this message translates to:
  /// **'Which of these gluten-free foods is high in fiber?'**
  String get question_42;

  /// No description provided for @options_42.
  ///
  /// In en, this message translates to:
  /// **'White rice,Brown rice,Corn flakes,Puffed rice'**
  String get options_42;

  /// No description provided for @question_43.
  ///
  /// In en, this message translates to:
  /// **'Which flour is used in traditional Italian polenta?'**
  String get question_43;

  /// No description provided for @options_43.
  ///
  /// In en, this message translates to:
  /// **'Cornmeal,Wheat flour,Oat flour,Rye flour'**
  String get options_43;

  /// No description provided for @question_44.
  ///
  /// In en, this message translates to:
  /// **'Are French fries always gluten-free?'**
  String get question_44;

  /// No description provided for @options_44.
  ///
  /// In en, this message translates to:
  /// **'Yes,No,Only if fried in separate oil,Only homemade'**
  String get options_44;

  /// No description provided for @question_45.
  ///
  /// In en, this message translates to:
  /// **'Which candy is typically gluten-free?'**
  String get question_45;

  /// No description provided for @options_45.
  ///
  /// In en, this message translates to:
  /// **'Twizzlers,Reese’s Cups,KitKat,Wafers'**
  String get options_45;

  /// No description provided for @question_46.
  ///
  /// In en, this message translates to:
  /// **'Which of these grains is gluten-free?'**
  String get question_46;

  /// No description provided for @options_46.
  ///
  /// In en, this message translates to:
  /// **'Farro,Freekeh,Teff,Spelt'**
  String get options_46;

  /// No description provided for @question_47.
  ///
  /// In en, this message translates to:
  /// **'What gluten-free flour is often used in baking?'**
  String get question_47;

  /// No description provided for @options_47.
  ///
  /// In en, this message translates to:
  /// **'Wheat flour,Rice flour,Semolina,Durum wheat'**
  String get options_47;

  /// No description provided for @question_48.
  ///
  /// In en, this message translates to:
  /// **'Which of these GF grains is a seed?'**
  String get question_48;

  /// No description provided for @options_48.
  ///
  /// In en, this message translates to:
  /// **'Quinoa,Wheat,Rye,Barley'**
  String get options_48;

  /// No description provided for @question_49.
  ///
  /// In en, this message translates to:
  /// **'What is a common gluten-free pizza crust made from?'**
  String get question_49;

  /// No description provided for @options_49.
  ///
  /// In en, this message translates to:
  /// **'Wheat,Oats,Cauliflower,Rye'**
  String get options_49;

  /// No description provided for @question_50.
  ///
  /// In en, this message translates to:
  /// **'Which alcoholic drink is NOT gluten-free?'**
  String get question_50;

  /// No description provided for @options_50.
  ///
  /// In en, this message translates to:
  /// **'Wine,Cider,Whiskey,Beer'**
  String get options_50;

  /// No description provided for @question_51.
  ///
  /// In en, this message translates to:
  /// **'Which of these is naturally gluten-free?'**
  String get question_51;

  /// No description provided for @options_51.
  ///
  /// In en, this message translates to:
  /// **'Couscous,Millet,Spelt,Bulgar'**
  String get options_51;

  /// No description provided for @question_52.
  ///
  /// In en, this message translates to:
  /// **'Is soy sauce gluten-free?'**
  String get question_52;

  /// No description provided for @options_52.
  ///
  /// In en, this message translates to:
  /// **'Yes,No,Only tamari sauce is,Only organic soy sauce is'**
  String get options_52;

  /// No description provided for @question_53.
  ///
  /// In en, this message translates to:
  /// **'Which flour is often used in gluten-free baking?'**
  String get question_53;

  /// No description provided for @options_53.
  ///
  /// In en, this message translates to:
  /// **'Spelt,Chickpea flour,Wheat flour,Durum wheat'**
  String get options_53;

  /// No description provided for @question_54.
  ///
  /// In en, this message translates to:
  /// **'Which soup is usually gluten-free?'**
  String get question_54;

  /// No description provided for @options_54.
  ///
  /// In en, this message translates to:
  /// **'Minestrone,Clam chowder,Tomato soup,French onion soup'**
  String get options_54;

  /// No description provided for @question_55.
  ///
  /// In en, this message translates to:
  /// **'Which of these is safe for celiacs?'**
  String get question_55;

  /// No description provided for @options_55.
  ///
  /// In en, this message translates to:
  /// **'Malt vinegar,Oats (certified GF),Wheat germ,Barley malt'**
  String get options_55;

  /// No description provided for @question_56.
  ///
  /// In en, this message translates to:
  /// **'Which of these protein sources is naturally GF?'**
  String get question_56;

  /// No description provided for @options_56.
  ///
  /// In en, this message translates to:
  /// **'Seitan,Tofu,Barley protein,Rye protein'**
  String get options_56;

  /// No description provided for @question_57.
  ///
  /// In en, this message translates to:
  /// **'Which of these grains is commonly used in gluten-free beer?'**
  String get question_57;

  /// No description provided for @options_57.
  ///
  /// In en, this message translates to:
  /// **'Barley,Sorghum,Rye,Spelt'**
  String get options_57;

  /// No description provided for @question_58.
  ///
  /// In en, this message translates to:
  /// **'Which of these is NOT a gluten-free thickener?'**
  String get question_58;

  /// No description provided for @options_58.
  ///
  /// In en, this message translates to:
  /// **'Cornstarch,Rice flour,Wheat flour,Arrowroot'**
  String get options_58;

  /// No description provided for @question_59.
  ///
  /// In en, this message translates to:
  /// **'Can gluten-free foods still cause cross-contamination?'**
  String get question_59;

  /// No description provided for @options_59.
  ///
  /// In en, this message translates to:
  /// **'Yes,No,Only when cooked,Only when eaten with gluten'**
  String get options_59;

  /// No description provided for @question_60.
  ///
  /// In en, this message translates to:
  /// **'Which of these is a naturally gluten-free sweetener?'**
  String get question_60;

  /// No description provided for @options_60.
  ///
  /// In en, this message translates to:
  /// **'Malt syrup,Honey,Barley malt extract,Wheat syrup'**
  String get options_60;

  /// No description provided for @question_61.
  ///
  /// In en, this message translates to:
  /// **'What gluten-free grain is used in Ethiopian injera bread?'**
  String get question_61;

  /// No description provided for @options_61.
  ///
  /// In en, this message translates to:
  /// **'Rye,Teff,Barley,Spelt'**
  String get options_61;

  /// No description provided for @question_62.
  ///
  /// In en, this message translates to:
  /// **'Which of these cheeses is always gluten-free?'**
  String get question_62;

  /// No description provided for @options_62.
  ///
  /// In en, this message translates to:
  /// **'Blue cheese,Cheddar,Processed cheese,Flavored cheese'**
  String get options_62;

  /// No description provided for @question_63.
  ///
  /// In en, this message translates to:
  /// **'Which grain is safe for a GF diet?'**
  String get question_63;

  /// No description provided for @options_63.
  ///
  /// In en, this message translates to:
  /// **'Wheat,Oats (certified GF),Barley,Rye'**
  String get options_63;

  /// No description provided for @question_64.
  ///
  /// In en, this message translates to:
  /// **'Which gluten-free flour works well for thickening soups?'**
  String get question_64;

  /// No description provided for @options_64.
  ///
  /// In en, this message translates to:
  /// **'Rice flour,Wheat flour,Semolina,Rye flour'**
  String get options_64;

  /// No description provided for @question_65.
  ///
  /// In en, this message translates to:
  /// **'Which flour is commonly used in gluten-free bread?'**
  String get question_65;

  /// No description provided for @options_65.
  ///
  /// In en, this message translates to:
  /// **'Rye flour,Tapioca flour,Durum wheat,Spelt'**
  String get options_65;

  /// No description provided for @question_66.
  ///
  /// In en, this message translates to:
  /// **'What common breakfast item is often NOT gluten-free?'**
  String get question_66;

  /// No description provided for @options_66.
  ///
  /// In en, this message translates to:
  /// **'Eggs,Pancakes,Smoothies,Bacon'**
  String get options_66;

  /// No description provided for @question_67.
  ///
  /// In en, this message translates to:
  /// **'Which ingredient should be checked for hidden gluten?'**
  String get question_67;

  /// No description provided for @options_67.
  ///
  /// In en, this message translates to:
  /// **'Sugar,Salt,Soy sauce,Pepper'**
  String get options_67;

  /// No description provided for @question_68.
  ///
  /// In en, this message translates to:
  /// **'Which food is gluten-free?'**
  String get question_68;

  /// No description provided for @options_68.
  ///
  /// In en, this message translates to:
  /// **'Pita bread,Brown rice,Couscous,Wheat crackers'**
  String get options_68;

  /// No description provided for @question_69.
  ///
  /// In en, this message translates to:
  /// **'Which of these breakfast foods is naturally GF?'**
  String get question_69;

  /// No description provided for @options_69.
  ///
  /// In en, this message translates to:
  /// **'Granola bars,Oatmeal (certified GF),Waffles,French toast'**
  String get options_69;

  /// No description provided for @question_70.
  ///
  /// In en, this message translates to:
  /// **'Which of these is safe for someone with gluten intolerance?'**
  String get question_70;

  /// No description provided for @options_70.
  ///
  /// In en, this message translates to:
  /// **'Whole wheat bread,Quinoa salad,Barley soup,Spelt muffins'**
  String get options_70;

  /// No description provided for @question_71.
  ///
  /// In en, this message translates to:
  /// **'Which of these is a gluten-free pasta alternative?'**
  String get question_71;

  /// No description provided for @options_71.
  ///
  /// In en, this message translates to:
  /// **'Semolina pasta,Wheat noodles,Lentil pasta,Egg noodles'**
  String get options_71;

  /// No description provided for @question_72.
  ///
  /// In en, this message translates to:
  /// **'Which fast-food chain offers gluten-free options?'**
  String get question_72;

  /// No description provided for @options_72.
  ///
  /// In en, this message translates to:
  /// **'KFC,Chipotle,Pizza Hut,Subway'**
  String get options_72;

  /// No description provided for @question_73.
  ///
  /// In en, this message translates to:
  /// **'What is a common gluten-free breakfast option?'**
  String get question_73;

  /// No description provided for @options_73.
  ///
  /// In en, this message translates to:
  /// **'Wheat toast,Oatmeal (certified GF),Bagels,Croissants'**
  String get options_73;

  /// No description provided for @question_74.
  ///
  /// In en, this message translates to:
  /// **'Which of these is a gluten-free snack?'**
  String get question_74;

  /// No description provided for @options_74.
  ///
  /// In en, this message translates to:
  /// **'Pretzels,Popcorn,Crackers,Wheat thins'**
  String get options_74;

  /// No description provided for @question_75.
  ///
  /// In en, this message translates to:
  /// **'Which thickening agent is gluten-free?'**
  String get question_75;

  /// No description provided for @options_75.
  ///
  /// In en, this message translates to:
  /// **'Flour,Cornstarch,Wheat starch,Roux'**
  String get options_75;

  /// No description provided for @question_76.
  ///
  /// In en, this message translates to:
  /// **'Which of these grains is NOT gluten-free?'**
  String get question_76;

  /// No description provided for @options_76.
  ///
  /// In en, this message translates to:
  /// **'Rice,Quinoa,Barley,Buckwheat'**
  String get options_76;

  /// No description provided for @question_77.
  ///
  /// In en, this message translates to:
  /// **'Which of these alcoholic drinks is gluten-free?'**
  String get question_77;

  /// No description provided for @options_77.
  ///
  /// In en, this message translates to:
  /// **'Beer,Whiskey,Vodka (potato-based),Malt liquor'**
  String get options_77;

  /// No description provided for @question_78.
  ///
  /// In en, this message translates to:
  /// **'Which of these dairy products is always gluten-free?'**
  String get question_78;

  /// No description provided for @options_78.
  ///
  /// In en, this message translates to:
  /// **'Yogurt,Ice cream,Plain milk,Flavored milk'**
  String get options_78;

  /// No description provided for @question_79.
  ///
  /// In en, this message translates to:
  /// **'Which of these foods is naturally gluten-free?'**
  String get question_79;

  /// No description provided for @options_79.
  ///
  /// In en, this message translates to:
  /// **'Soy sauce,Couscous,Lentils,Wheat tortillas'**
  String get options_79;

  /// No description provided for @question_80.
  ///
  /// In en, this message translates to:
  /// **'What is a sign of gluten intolerance?'**
  String get question_80;

  /// No description provided for @options_80.
  ///
  /// In en, this message translates to:
  /// **'Skin rash,Blurred vision,Excessive sweating,Ear infection'**
  String get options_80;

  /// No description provided for @question_81.
  ///
  /// In en, this message translates to:
  /// **'Which of these is a gluten-free grain?'**
  String get question_81;

  /// No description provided for @options_81.
  ///
  /// In en, this message translates to:
  /// **'Kamut,Millet,Spelt,Barley'**
  String get options_81;

  /// No description provided for @question_82.
  ///
  /// In en, this message translates to:
  /// **'Which dessert is usually gluten-free?'**
  String get question_82;

  /// No description provided for @options_82.
  ///
  /// In en, this message translates to:
  /// **'Cheesecake,Macarons,Chocolate cake,Brownies'**
  String get options_82;

  /// No description provided for @question_83.
  ///
  /// In en, this message translates to:
  /// **'Which of these soups is gluten-free?'**
  String get question_83;

  /// No description provided for @options_83.
  ///
  /// In en, this message translates to:
  /// **'Miso soup,Cream of mushroom,French onion soup,Clam chowder'**
  String get options_83;

  /// No description provided for @question_84.
  ///
  /// In en, this message translates to:
  /// **'Which meat is safe for a gluten-free diet?'**
  String get question_84;

  /// No description provided for @options_84.
  ///
  /// In en, this message translates to:
  /// **'Breaded chicken,Plain grilled steak,Meatballs,Sausages'**
  String get options_84;

  /// No description provided for @question_85.
  ///
  /// In en, this message translates to:
  /// **'Which of these sauces is gluten-free?'**
  String get question_85;

  /// No description provided for @options_85.
  ///
  /// In en, this message translates to:
  /// **'Soy sauce,Tomato sauce,Teriyaki sauce,Worcestershire sauce'**
  String get options_85;

  /// No description provided for @question_86.
  ///
  /// In en, this message translates to:
  /// **'Which pasta alternative is gluten-free?'**
  String get question_86;

  /// No description provided for @options_86.
  ///
  /// In en, this message translates to:
  /// **'Whole wheat pasta,Semolina pasta,Zucchini noodles,Egg noodles'**
  String get options_86;

  /// No description provided for @question_87.
  ///
  /// In en, this message translates to:
  /// **'Which type of bread is gluten-free?'**
  String get question_87;

  /// No description provided for @options_87.
  ///
  /// In en, this message translates to:
  /// **'Rye bread,Baguette,Cornbread (made with GF ingredients),Ciabatta'**
  String get options_87;

  /// No description provided for @question_88.
  ///
  /// In en, this message translates to:
  /// **'Which of these is a gluten-free treat?'**
  String get question_88;

  /// No description provided for @options_88.
  ///
  /// In en, this message translates to:
  /// **'Doughnuts,Rice pudding,Cupcakes,Waffles'**
  String get options_88;

  /// No description provided for @question_89.
  ///
  /// In en, this message translates to:
  /// **'What is a common gluten-free grain?'**
  String get question_89;

  /// No description provided for @options_89.
  ///
  /// In en, this message translates to:
  /// **'Barley,Farro,Sorghum,Wheat'**
  String get options_89;

  /// No description provided for @question_90.
  ///
  /// In en, this message translates to:
  /// **'Which of these is NOT naturally gluten-free?'**
  String get question_90;

  /// No description provided for @options_90.
  ///
  /// In en, this message translates to:
  /// **'Eggs,Chicken,Soy sauce,Potatoes'**
  String get options_90;

  /// No description provided for @question_91.
  ///
  /// In en, this message translates to:
  /// **'Which seasoning should be checked for gluten?'**
  String get question_91;

  /// No description provided for @options_91.
  ///
  /// In en, this message translates to:
  /// **'Salt,Pepper,Soy sauce,Paprika'**
  String get options_91;

  /// No description provided for @question_92.
  ///
  /// In en, this message translates to:
  /// **'What is a gluten-free thickener for soups?'**
  String get question_92;

  /// No description provided for @options_92.
  ///
  /// In en, this message translates to:
  /// **'Roux,Wheat flour,Cornstarch,Malt powder'**
  String get options_92;

  /// No description provided for @question_93.
  ///
  /// In en, this message translates to:
  /// **'Which restaurant meal is most likely gluten-free?'**
  String get question_93;

  /// No description provided for @options_93.
  ///
  /// In en, this message translates to:
  /// **'Pasta Alfredo,Grilled salmon with steamed veggies,Chicken tenders,Breaded shrimp'**
  String get options_93;

  /// No description provided for @question_94.
  ///
  /// In en, this message translates to:
  /// **'Which salad dressing is typically gluten-free?'**
  String get question_94;

  /// No description provided for @options_94.
  ///
  /// In en, this message translates to:
  /// **'Caesar,Vinaigrette,Ranch,Thousand Island'**
  String get options_94;

  /// No description provided for @question_95.
  ///
  /// In en, this message translates to:
  /// **'Which beer ingredient contains gluten?'**
  String get question_95;

  /// No description provided for @options_95.
  ///
  /// In en, this message translates to:
  /// **'Hops,Yeast,Barley,Water'**
  String get options_95;

  /// No description provided for @question_96.
  ///
  /// In en, this message translates to:
  /// **'Which common kitchen ingredient often contains hidden gluten?'**
  String get question_96;

  /// No description provided for @options_96.
  ///
  /// In en, this message translates to:
  /// **'Sugar,Flour,Butter,Olive oil'**
  String get options_96;

  /// No description provided for @question_97.
  ///
  /// In en, this message translates to:
  /// **'Which restaurant cuisine has the most gluten-free options?'**
  String get question_97;

  /// No description provided for @options_97.
  ///
  /// In en, this message translates to:
  /// **'Italian,Japanese,Mexican,French'**
  String get options_97;

  /// No description provided for @question_98.
  ///
  /// In en, this message translates to:
  /// **'Which of these is NOT a gluten-free cereal?'**
  String get question_98;

  /// No description provided for @options_98.
  ///
  /// In en, this message translates to:
  /// **'Rice Krispies,Corn Flakes,Oatmeal (certified GF),Chex'**
  String get options_98;

  /// No description provided for @question_99.
  ///
  /// In en, this message translates to:
  /// **'Which of these grains can be used for GF baking?'**
  String get question_99;

  /// No description provided for @options_99.
  ///
  /// In en, this message translates to:
  /// **'Barley,Wheat,Quinoa,Spelt'**
  String get options_99;

  /// No description provided for @question_100.
  ///
  /// In en, this message translates to:
  /// **'What is a gluten-free source of protein?'**
  String get question_100;

  /// No description provided for @options_100.
  ///
  /// In en, this message translates to:
  /// **'Seitan,Tempeh,Lentils,Couscous'**
  String get options_100;

  /// No description provided for @selectGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a game'**
  String get selectGameMessage;

  /// No description provided for @snakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Snake'**
  String get snakeTitle;

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quizTitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @scoreStartOverMessage.
  ///
  /// In en, this message translates to:
  /// **'Your score: {score_start_over}. Do you want to start over?'**
  String scoreStartOverMessage(Object score_start_over);

  /// No description provided for @restartText.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartText;

  /// No description provided for @currentScore.
  ///
  /// In en, this message translates to:
  /// **'Snake Game - Score: {snake_score}'**
  String currentScore(Object snake_score);

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed'**
  String get quizCompleted;

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'Your score: {quiz_final_score} / 20'**
  String quizScore(Object quiz_final_score);

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @glutenQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Gluten-Free Quiz'**
  String get glutenQuizTitle;

  /// No description provided for @progressQuiz.
  ///
  /// In en, this message translates to:
  /// **'Question {quiz_progress}/20'**
  String progressQuiz(Object quiz_progress);

  /// No description provided for @copiedToClipboardText.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboardText;

  /// No description provided for @tapForDetailsText.
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get tapForDetailsText;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orText;

  /// No description provided for @noAccountText.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountText;

  /// No description provided for @forgotPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordText;

  /// No description provided for @heightText.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightText;

  /// No description provided for @widthText.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get widthText;

  /// No description provided for @imageProcessingErrorText.
  ///
  /// In en, this message translates to:
  /// **'Image processing error'**
  String get imageProcessingErrorText;

  /// No description provided for @accountText.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountText;

  /// No description provided for @appearanceText.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceText;

  /// No description provided for @aboutAppTab.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutAppTab;

  /// No description provided for @appPurposeContent.
  ///
  /// In en, this message translates to:
  /// **'This app is designed to help people with celiac disease or gluten intolerance by providing a secure e-commerce platform, adapted recipes, educational games, and resources to maintain a safe gluten-free lifestyle.'**
  String get appPurposeContent;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get featuresTitle;

  /// No description provided for @feature1.
  ///
  /// In en, this message translates to:
  /// **'🛒 **Gluten-Free Online Store** - Shop with confidence for certified gluten-free products with direct delivery.'**
  String get feature1;

  /// No description provided for @feature2.
  ///
  /// In en, this message translates to:
  /// **'🎮 **Educational Mini-Games** - Learn to identify safe foods in a fun way with our interactive games.'**
  String get feature2;

  /// No description provided for @feature3.
  ///
  /// In en, this message translates to:
  /// **'🍽 **Gluten-Free Recipes** - Discover delicious and safe meal ideas created by nutrition experts.'**
  String get feature3;

  /// No description provided for @feature4.
  ///
  /// In en, this message translates to:
  /// **'📍 **Local Business Directory** - Find certified gluten-free grocery stores and restaurants near you.'**
  String get feature4;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'gluttex.team@gmail.com'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'+213-XXX-XXX-XXX'**
  String get contactPhone;

  /// No description provided for @illnessOverviewContent.
  ///
  /// In en, this message translates to:
  /// **'Celiac disease is an autoimmune disorder where gluten ingestion damages the small intestine. It can cause digestive problems, nutritional deficiencies, and other complications. Strict lifelong gluten avoidance is the only effective treatment.'**
  String get illnessOverviewContent;

  /// No description provided for @symptom1.
  ///
  /// In en, this message translates to:
  /// **'💨 **Digestive Issues** - Bloating, diarrhea, constipation, nausea and vomiting.'**
  String get symptom1;

  /// No description provided for @symptom2.
  ///
  /// In en, this message translates to:
  /// **'⚡ **Chronic Fatigue** - Caused by malabsorption of essential nutrients.'**
  String get symptom2;

  /// No description provided for @symptom3.
  ///
  /// In en, this message translates to:
  /// **'🦴 **Bone Complications** - Increased risk of osteoporosis due to poor calcium and vitamin D absorption.'**
  String get symptom3;

  /// No description provided for @treatmentContent.
  ///
  /// In en, this message translates to:
  /// **'Treatment requires strict lifelong gluten-free diet. Patients must avoid wheat, barley, rye and their derivatives. Nutritional support and tools like Gluttex help prevent accidental exposure.'**
  String get treatmentContent;

  /// No description provided for @resource1.
  ///
  /// In en, this message translates to:
  /// **'📖 **Celiac Disease Foundation** - [www.celiac.org](https://www.celiac.org)'**
  String get resource1;

  /// No description provided for @resource2.
  ///
  /// In en, this message translates to:
  /// **'📱 **Interactive Shopping Guide** - Built-in app feature to scan suspicious ingredient lists.'**
  String get resource2;

  /// No description provided for @resource3.
  ///
  /// In en, this message translates to:
  /// **'👩‍⚕️ **Specialist Directory** - Find gastroenterologists and nutritionists specializing in celiac disease near you.'**
  String get resource3;

  /// No description provided for @resourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Useful Resources'**
  String get resourcesTitle;

  /// No description provided for @userCredentialsText.
  ///
  /// In en, this message translates to:
  /// **'Your login credentials include your username and password. Make sure to keep them secure and do not share them with anyone.'**
  String get userCredentialsText;

  /// No description provided for @processingRequest.
  ///
  /// In en, this message translates to:
  /// **'Processing your request...'**
  String get processingRequest;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @locationInformation.
  ///
  /// In en, this message translates to:
  /// **'Location Information'**
  String get locationInformation;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @saveSupplier.
  ///
  /// In en, this message translates to:
  /// **'Save Supplier'**
  String get saveSupplier;

  /// No description provided for @healthText.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthText;

  /// No description provided for @illnessOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Celiac Disease?'**
  String get illnessOverviewTitle;

  /// No description provided for @symptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Common Symptoms'**
  String get symptomsTitle;

  /// No description provided for @illnessInfoTab.
  ///
  /// In en, this message translates to:
  /// **'Informations'**
  String get illnessInfoTab;

  /// No description provided for @appPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get appPurposeTitle;

  /// No description provided for @treatmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Treatment & Management'**
  String get treatmentTitle;

  /// No description provided for @internal_server_error.
  ///
  /// In en, this message translates to:
  /// **'Internal server error. Please try again later.'**
  String get internal_server_error;

  /// No description provided for @http_exception.
  ///
  /// In en, this message translates to:
  /// **'HTTP request failed. Check your connection.'**
  String get http_exception;

  /// No description provided for @integrity_error.
  ///
  /// In en, this message translates to:
  /// **'Data integrity violation. The operation cannot be completed.'**
  String get integrity_error;

  /// No description provided for @data_error.
  ///
  /// In en, this message translates to:
  /// **'Invalid data format. Please verify your input.'**
  String get data_error;

  /// No description provided for @operational_error.
  ///
  /// In en, this message translates to:
  /// **'An operational error occurred. Contact support if the issue persists.'**
  String get operational_error;

  /// No description provided for @programming_error.
  ///
  /// In en, this message translates to:
  /// **'A programming error occurred. Developers have been notified.'**
  String get programming_error;

  /// No description provided for @database_error.
  ///
  /// In en, this message translates to:
  /// **'Database operation failed. Try again or contact support.'**
  String get database_error;

  /// No description provided for @internal_error.
  ///
  /// In en, this message translates to:
  /// **'An internal system error occurred.'**
  String get internal_error;

  /// No description provided for @interface_error.
  ///
  /// In en, this message translates to:
  /// **'Interface communication failed. Check configurations.'**
  String get interface_error;

  /// No description provided for @statement_error.
  ///
  /// In en, this message translates to:
  /// **'Invalid SQL statement. Syntax or logic error detected.'**
  String get statement_error;

  /// No description provided for @incorrect_credentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password'**
  String get incorrect_credentials;

  /// No description provided for @sqlalchemy_error.
  ///
  /// In en, this message translates to:
  /// **'SQLAlchemy database error. Check query or connection.'**
  String get sqlalchemy_error;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @passwordChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get passwordChangeTitle;

  /// No description provided for @passwordChangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from previous passwords'**
  String get passwordChangeSubtitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @currentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get currentPasswordHint;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get newPasswordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get confirmPasswordHint;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordButton;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must contain:'**
  String get passwordRequirements;

  /// No description provided for @passwordLengthRequirement.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordLengthRequirement;

  /// No description provided for @passwordUppercaseRequirement.
  ///
  /// In en, this message translates to:
  /// **'At least 1 uppercase letter'**
  String get passwordUppercaseRequirement;

  /// No description provided for @passwordNumberRequirement.
  ///
  /// In en, this message translates to:
  /// **'At least 1 number'**
  String get passwordNumberRequirement;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangeSuccess;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Weak password'**
  String get weakPassword;

  /// No description provided for @mediumPassword.
  ///
  /// In en, this message translates to:
  /// **'Medium strength'**
  String get mediumPassword;

  /// No description provided for @strongPassword.
  ///
  /// In en, this message translates to:
  /// **'Strong password'**
  String get strongPassword;

  /// No description provided for @categoryText.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryText;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// No description provided for @passwordUppercaseError.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least one uppercase letter'**
  String get passwordUppercaseError;

  /// No description provided for @passwordNumberError.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least one number'**
  String get passwordNumberError;

  /// No description provided for @passwordSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get passwordSameAsCurrent;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @changePhotoText.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changePhotoText;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Field is required'**
  String get fieldRequired;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdateSuccess;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @logoutText.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutText;

  /// No description provided for @continueAsGuestText.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuestText;

  /// No description provided for @ingredientText.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientText;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsTitle;

  /// No description provided for @termsContent.
  ///
  /// In en, this message translates to:
  /// **'By using this app you agree to:'**
  String get termsContent;

  /// No description provided for @termsPoint1.
  ///
  /// In en, this message translates to:
  /// **'Use the app only for personal purposes'**
  String get termsPoint1;

  /// No description provided for @termsPoint2.
  ///
  /// In en, this message translates to:
  /// **'Not redistribute gluten-free recipes commercially'**
  String get termsPoint2;

  /// No description provided for @termsPoint3.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge potential recipe variations'**
  String get termsPoint3;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get guideTitle;

  /// No description provided for @guideStep1.
  ///
  /// In en, this message translates to:
  /// **'Create your profile to save preferences'**
  String get guideStep1;

  /// No description provided for @guideStep2.
  ///
  /// In en, this message translates to:
  /// **'Search recipes by ingredients or dietary needs'**
  String get guideStep2;

  /// No description provided for @guideStep3.
  ///
  /// In en, this message translates to:
  /// **'Bookmark favorites for quick access'**
  String get guideStep3;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Disclaimer'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerContent.
  ///
  /// In en, this message translates to:
  /// **'While we verify recipes, always check labels as manufacturers may change ingredients.'**
  String get disclaimerContent;

  /// No description provided for @versionText.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get versionText;

  /// No description provided for @providedBy.
  ///
  /// In en, this message translates to:
  /// **'Provided by'**
  String get providedBy;

  /// No description provided for @unknownProvider.
  ///
  /// In en, this message translates to:
  /// **'Unknown provider'**
  String get unknownProvider;

  /// No description provided for @callProvider.
  ///
  /// In en, this message translates to:
  /// **'Call provider'**
  String get callProvider;

  /// No description provided for @emailProvider.
  ///
  /// In en, this message translates to:
  /// **'Email provider'**
  String get emailProvider;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMap;

  /// No description provided for @providerContactOptions.
  ///
  /// In en, this message translates to:
  /// **'Contact Options'**
  String get providerContactOptions;

  /// No description provided for @supplierText.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplierText;

  /// No description provided for @legalDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Documents'**
  String get legalDocumentsTitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @termsAgreementText.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Use governing my use of Gluttex'**
  String get termsAgreementText;

  /// No description provided for @privacyAgreementText.
  ///
  /// In en, this message translates to:
  /// **'I agree to how Gluttex collects and processes my data'**
  String get privacyAgreementText;

  /// No description provided for @readFullDocument.
  ///
  /// In en, this message translates to:
  /// **'Read full document'**
  String get readFullDocument;

  /// No description provided for @acceptAllTermsError.
  ///
  /// In en, this message translates to:
  /// **'You must accept both documents to continue'**
  String get acceptAllTermsError;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @availableText.
  ///
  /// In en, this message translates to:
  /// **'{amount} Available'**
  String availableText(Object amount);

  /// No description provided for @ingredientUnits.
  ///
  /// In en, this message translates to:
  /// **'Gram,Kilogram,Milligram,Pound,Ounce,Milliliter,Liter,Cup,Tablespoon,Teaspoon,Pinch'**
  String get ingredientUnits;

  /// No description provided for @unitText.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitText;

  /// No description provided for @amountText.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountText;

  /// No description provided for @otherProductsFromSupplier.
  ///
  /// In en, this message translates to:
  /// **'Also from: {supplier_name}'**
  String otherProductsFromSupplier(Object supplier_name);

  /// No description provided for @productsFromSupplier.
  ///
  /// In en, this message translates to:
  /// **'Provided by: {supplier_name}'**
  String productsFromSupplier(Object supplier_name);

  /// No description provided for @similarProductsFromCategory.
  ///
  /// In en, this message translates to:
  /// **'Products from: {category_name}'**
  String similarProductsFromCategory(Object category_name);

  /// No description provided for @noOtherProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available from this supplier.'**
  String get noOtherProductsAvailable;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @imagePickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get imagePickFailed;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @searchSuppliersText.
  ///
  /// In en, this message translates to:
  /// **'Search suppliers...'**
  String get searchSuppliersText;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @selectOrganisationHintText.
  ///
  /// In en, this message translates to:
  /// **'Please select an organisation'**
  String get selectOrganisationHintText;

  /// No description provided for @providerImage.
  ///
  /// In en, this message translates to:
  /// **'Provider Image'**
  String get providerImage;

  /// No description provided for @selectOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Select Organisation'**
  String get selectOrganisation;

  /// No description provided for @searchOrganisations.
  ///
  /// In en, this message translates to:
  /// **'Search Organisations'**
  String get searchOrganisations;

  /// No description provided for @noOrganisationsFound.
  ///
  /// In en, this message translates to:
  /// **'No organisations found'**
  String get noOrganisationsFound;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get createNew;

  String getLocalizedQuestion(int index) {
    switch (index) {
      case 1:
        return question_1;
      case 2:
        return question_2;
      case 3:
        return question_3;
      case 4:
        return question_4;
      case 5:
        return question_5;
      case 6:
        return question_6;
      case 7:
        return question_7;
      case 8:
        return question_8;
      case 9:
        return question_9;
      case 10:
        return question_10;
      case 11:
        return question_11;
      case 12:
        return question_12;
      case 13:
        return question_13;
      case 14:
        return question_14;
      case 15:
        return question_15;
      case 16:
        return question_16;
      case 17:
        return question_17;
      case 18:
        return question_18;
      case 19:
        return question_19;
      case 20:
        return question_20;
      case 21:
        return question_21;
      case 22:
        return question_22;
      case 23:
        return question_23;
      case 24:
        return question_24;
      case 25:
        return question_25;
      case 26:
        return question_26;
      case 27:
        return question_27;
      case 28:
        return question_28;
      case 29:
        return question_29;
      case 30:
        return question_30;
      case 31:
        return question_31;
      case 32:
        return question_32;
      case 33:
        return question_33;
      case 34:
        return question_34;
      case 35:
        return question_35;
      case 36:
        return question_36;
      case 37:
        return question_37;
      case 38:
        return question_38;
      case 39:
        return question_39;
      case 40:
        return question_40;
      case 41:
        return question_41;
      case 42:
        return question_42;
      case 43:
        return question_43;
      case 44:
        return question_44;
      case 45:
        return question_45;
      case 46:
        return question_46;
      case 47:
        return question_47;
      case 48:
        return question_48;
      case 49:
        return question_49;
      case 50:
        return question_50;
      case 51:
        return question_51;
      case 52:
        return question_52;
      case 53:
        return question_53;
      case 54:
        return question_54;
      case 55:
        return question_55;
      case 56:
        return question_56;
      case 57:
        return question_57;
      case 58:
        return question_58;
      case 59:
        return question_59;
      case 60:
        return question_60;
      case 61:
        return question_61;
      case 62:
        return question_62;
      case 63:
        return question_63;
      case 64:
        return question_64;
      case 65:
        return question_65;
      case 66:
        return question_66;
      case 67:
        return question_67;
      case 68:
        return question_68;
      case 69:
        return question_69;
      case 70:
        return question_70;
      case 71:
        return question_71;
      case 72:
        return question_72;
      case 73:
        return question_73;
      case 74:
        return question_74;
      case 75:
        return question_75;
      case 76:
        return question_76;
      case 77:
        return question_77;
      case 78:
        return question_78;
      case 79:
        return question_79;
      case 80:
        return question_80;
      case 81:
        return question_81;
      case 82:
        return question_82;
      case 83:
        return question_83;
      case 84:
        return question_84;
      case 85:
        return question_85;
      case 86:
        return question_86;
      case 87:
        return question_87;
      case 88:
        return question_88;
      case 89:
        return question_89;
      case 90:
        return question_90;
      case 91:
        return question_91;
      case 92:
        return question_92;
      case 93:
        return question_93;
      case 94:
        return question_94;
      case 95:
        return question_95;
      case 96:
        return question_96;
      case 97:
        return question_97;
      case 98:
        return question_98;
      case 99:
        return question_99;
      case 100:
        return question_100;
      default:
        return notFoundError;
    }
  }

  String getLocalizedAnswerList(int index) {
    switch (index) {
      case 1:
        return options_1;
      case 2:
        return options_2;
      case 3:
        return options_3;
      case 4:
        return options_4;
      case 5:
        return options_5;
      case 6:
        return options_6;
      case 7:
        return options_7;
      case 8:
        return options_8;
      case 9:
        return options_9;
      case 10:
        return options_10;
      case 11:
        return options_11;
      case 12:
        return options_12;
      case 13:
        return options_13;
      case 14:
        return options_14;
      case 15:
        return options_15;
      case 16:
        return options_16;
      case 17:
        return options_17;
      case 18:
        return options_18;
      case 19:
        return options_19;
      case 20:
        return options_20;
      case 21:
        return options_21;
      case 22:
        return options_22;
      case 23:
        return options_23;
      case 24:
        return options_24;
      case 25:
        return options_25;
      case 26:
        return options_26;
      case 27:
        return options_27;
      case 28:
        return options_28;
      case 29:
        return options_29;
      case 30:
        return options_30;
      case 31:
        return options_31;
      case 32:
        return options_32;
      case 33:
        return options_33;
      case 34:
        return options_34;
      case 35:
        return options_35;
      case 36:
        return options_36;
      case 37:
        return options_37;
      case 38:
        return options_38;
      case 39:
        return options_39;
      case 40:
        return options_40;
      case 41:
        return options_41;
      case 42:
        return options_42;
      case 43:
        return options_43;
      case 44:
        return options_44;
      case 45:
        return options_45;
      case 46:
        return options_46;
      case 47:
        return options_47;
      case 48:
        return options_48;
      case 49:
        return options_49;
      case 50:
        return options_50;
      case 51:
        return options_51;
      case 52:
        return options_52;
      case 53:
        return options_53;
      case 54:
        return options_54;
      case 55:
        return options_55;
      case 56:
        return options_56;
      case 57:
        return options_57;
      case 58:
        return options_58;
      case 59:
        return options_59;
      case 60:
        return options_60;
      case 61:
        return options_61;
      case 62:
        return options_62;
      case 63:
        return options_63;
      case 64:
        return options_64;
      case 65:
        return options_65;
      case 66:
        return options_66;
      case 67:
        return options_67;
      case 68:
        return options_68;
      case 69:
        return options_69;
      case 70:
        return options_70;
      case 71:
        return options_71;
      case 72:
        return options_72;
      case 73:
        return options_73;
      case 74:
        return options_74;
      case 75:
        return options_75;
      case 76:
        return options_76;
      case 77:
        return options_77;
      case 78:
        return options_78;
      case 79:
        return options_79;
      case 80:
        return options_80;
      case 81:
        return options_81;
      case 82:
        return options_82;
      case 83:
        return options_83;
      case 84:
        return options_84;
      case 85:
        return options_85;
      case 86:
        return options_86;
      case 87:
        return options_87;
      case 88:
        return options_88;
      case 89:
        return options_89;
      case 90:
        return options_90;
      case 91:
        return options_91;
      case 92:
        return options_92;
      case 93:
        return options_93;
      case 94:
        return options_94;
      case 95:
        return options_95;
      case 96:
        return options_96;
      case 97:
        return options_97;
      case 98:
        return options_98;
      case 99:
        return options_99;
      case 100:
        return options_100;
      default:
        return notFoundError;
    }
  }

  /// No description provided for @organisationText.
  ///
  /// In en, this message translates to:
  /// **'Organisation'**
  String get organisationText;

  /// No description provided for @by_organisation.
  ///
  /// In en, this message translates to:
  /// **'By {org_name}'**
  String by_organisation(Object org_name);

  /// No description provided for @no_location_information_available.
  ///
  /// In en, this message translates to:
  /// **'No available information about location'**
  String get no_location_information_available;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
