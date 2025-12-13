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
  /// **'Amount'**
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
  /// **'Please enter a product amount'**
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
  /// **'Product Amount'**
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
  /// **'Add'**
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
  /// **'Enter Amount'**
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
  /// **'Amount: {amount}'**
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

  /// No description provided for @orderFor.
  ///
  /// In en, this message translates to:
  /// **'Order for'**
  String get orderFor;

  /// No description provided for @missingProductName.
  ///
  /// In en, this message translates to:
  /// **'Product name missing'**
  String get missingProductName;

  /// No description provided for @amountTxtDisplay.
  ///
  /// In en, this message translates to:
  /// **'{amount} {quantifier}'**
  String amountTxtDisplay(Object amount, Object quantifier);

  /// No description provided for @quantifier_g.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get quantifier_g;

  /// No description provided for @quantifier_kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get quantifier_kg;

  /// No description provided for @quantifier_mg.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get quantifier_mg;

  /// No description provided for @quantifier_L.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get quantifier_L;

  /// No description provided for @quantifier_mL.
  ///
  /// In en, this message translates to:
  /// **'mL'**
  String get quantifier_mL;

  /// No description provided for @quantifier_pc.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get quantifier_pc;

  /// No description provided for @quantifier_pkg.
  ///
  /// In en, this message translates to:
  /// **'package'**
  String get quantifier_pkg;

  /// No description provided for @quantifier_box.
  ///
  /// In en, this message translates to:
  /// **'box'**
  String get quantifier_box;

  /// No description provided for @quantifier_bag.
  ///
  /// In en, this message translates to:
  /// **'bag'**
  String get quantifier_bag;

  /// No description provided for @quantifier_slice.
  ///
  /// In en, this message translates to:
  /// **'slice'**
  String get quantifier_slice;

  /// No description provided for @quantifier_cup.
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get quantifier_cup;

  /// No description provided for @order_number.
  ///
  /// In en, this message translates to:
  /// **'Order Number: {n}'**
  String order_number(Object n);

  /// No description provided for @orderItemsTxt.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItemsTxt;

  /// No description provided for @dateTimeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Date not available'**
  String get dateTimeNotAvailable;

  /// No description provided for @dateTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year} {hour}:{min}'**
  String dateTimeFormat(Object day, Object hour, Object min, Object month, Object year);

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year}'**
  String dateFormat(Object day, Object month, Object year);

  /// No description provided for @completedTxt.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTxt;

  /// No description provided for @deliveredTxt.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveredTxt;

  /// No description provided for @pendingTxt.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTxt;

  /// No description provided for @cancelledTxt.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledTxt;

  /// No description provided for @processingTxt.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processingTxt;

  /// No description provided for @unknownTxt.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownTxt;

  /// No description provided for @spentTxt.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spentTxt;

  /// No description provided for @qtyTxt.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity} × {price}'**
  String qtyTxt(Object price, Object quantity);

  /// No description provided for @loadingOrders.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingOrders;

  /// No description provided for @loadingOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading order details...'**
  String get loadingOrderDetails;

  /// No description provided for @failedToLoadDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load details'**
  String get failedToLoadDetails;

  /// No description provided for @yourOrdersWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here'**
  String get yourOrdersWillAppearHere;

  /// No description provided for @refreshTxt.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTxt;

  /// No description provided for @yourOrderStats.
  ///
  /// In en, this message translates to:
  /// **'Your Order Stats'**
  String get yourOrderStats;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploadingImage;

  /// No description provided for @laterText.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterText;

  /// No description provided for @failedAuthAfterSignIn.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed after signing in.'**
  String get failedAuthAfterSignIn;

  /// No description provided for @loginTimeoutMsg.
  ///
  /// In en, this message translates to:
  /// **'Login timed out. Please try again.'**
  String get loginTimeoutMsg;

  /// No description provided for @failedLogin.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check your credentials.'**
  String get failedLogin;

  /// No description provided for @signInWithText.
  ///
  /// In en, this message translates to:
  /// **'Sign in with'**
  String get signInWithText;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @loggingOutText.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOutText;

  /// No description provided for @logoutConsentText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConsentText;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @alignBarcode.
  ///
  /// In en, this message translates to:
  /// **'Align barcode within the frame'**
  String get alignBarcode;

  /// No description provided for @positionBarcode.
  ///
  /// In en, this message translates to:
  /// **'Position the barcode inside the scanning area for automatic detection'**
  String get positionBarcode;

  /// No description provided for @barcodeScanSuccess.
  ///
  /// In en, this message translates to:
  /// **'Barcode scanned successfully!'**
  String get barcodeScanSuccess;

  /// No description provided for @initCam.
  ///
  /// In en, this message translates to:
  /// **'Initializing Camera...'**
  String get initCam;

  /// No description provided for @captureProduct.
  ///
  /// In en, this message translates to:
  /// **'Capture Product'**
  String get captureProduct;

  /// No description provided for @positionProductInFrame.
  ///
  /// In en, this message translates to:
  /// **'Position Product in Frame'**
  String get positionProductInFrame;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Ensure good lighting and clear focus'**
  String get scanHint;

  /// No description provided for @tapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to Capture'**
  String get tapHint;

  /// No description provided for @reviewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Review Photo'**
  String get reviewPhoto;

  /// No description provided for @croppedToFrame.
  ///
  /// In en, this message translates to:
  /// **'Cropped to frame'**
  String get croppedToFrame;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use This Photo'**
  String get usePhoto;

  /// No description provided for @takeAgain.
  ///
  /// In en, this message translates to:
  /// **'Take Again'**
  String get takeAgain;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing Image...'**
  String get processingImage;

  /// No description provided for @waitText.
  ///
  /// In en, this message translates to:
  /// **'This may take a few seconds'**
  String get waitText;

  /// No description provided for @aiAnalysing.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing your product...'**
  String get aiAnalysing;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically fill product details'**
  String get aiAssistantSubtitle;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Product Assistant'**
  String get aiAssistantTitle;

  /// No description provided for @productDetailsFilled.
  ///
  /// In en, this message translates to:
  /// **'Product details filled automatically!'**
  String get productDetailsFilled;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQR;

  /// No description provided for @scannerHint.
  ///
  /// In en, this message translates to:
  /// **'Position QR Code in Frame'**
  String get scannerHint;

  /// No description provided for @alignQR.
  ///
  /// In en, this message translates to:
  /// **'Align the QR code within the scanning area for automatic detection'**
  String get alignQR;

  /// No description provided for @manualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual Input'**
  String get manualInput;

  /// No description provided for @qrSuccess.
  ///
  /// In en, this message translates to:
  /// **'QR Code scanned successfully!'**
  String get qrSuccess;

  /// No description provided for @manualQR.
  ///
  /// In en, this message translates to:
  /// **'Enter QR Code Manually'**
  String get manualQR;

  /// No description provided for @manualQRHint.
  ///
  /// In en, this message translates to:
  /// **'Paste or type QR code content...'**
  String get manualQRHint;

  /// No description provided for @scannerTxt.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scannerTxt;

  /// No description provided for @takeProductPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Product Photo'**
  String get takeProductPhoto;

  /// No description provided for @aiWillAnalyseImage.
  ///
  /// In en, this message translates to:
  /// **'AI will analyze the product image'**
  String get aiWillAnalyseImage;

  /// No description provided for @automaticallyFillDetailsFromBarcode.
  ///
  /// In en, this message translates to:
  /// **'Automatically fill details from barcode'**
  String get automaticallyFillDetailsFromBarcode;

  /// No description provided for @aiGenerated.
  ///
  /// In en, this message translates to:
  /// **'AI-Generated'**
  String get aiGenerated;

  /// No description provided for @databaseFetched.
  ///
  /// In en, this message translates to:
  /// **'Retrieved from database'**
  String get databaseFetched;

  /// No description provided for @userInput.
  ///
  /// In en, this message translates to:
  /// **'User-Provided'**
  String get userInput;

  /// No description provided for @notificationOrderReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Received! 🎉'**
  String get notificationOrderReceivedTitle;

  /// No description provided for @notificationRoleInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Team Invitation'**
  String get notificationRoleInvitationTitle;

  /// No description provided for @notificationProductUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Updated'**
  String get notificationProductUpdatedTitle;

  /// No description provided for @notificationDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationDefaultTitle;

  /// No description provided for @notificationOrderReceivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for processing'**
  String get notificationOrderReceivedSubtitle;

  /// No description provided for @notificationProductUpdatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New changes available'**
  String get notificationProductUpdatedSubtitle;

  /// No description provided for @notificationOrderReceivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order has been successfully received and is being processed. You can track its status in your orders.'**
  String get notificationOrderReceivedMessage;

  /// No description provided for @notificationRoleInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been invited to join \"{ruleName}\" as {ruleType}. Accept to get started!'**
  String notificationRoleInvitationMessage(Object ruleName, Object ruleType);

  /// No description provided for @notificationRoleInvitationDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been invited to join a team.'**
  String get notificationRoleInvitationDefaultMessage;

  /// No description provided for @notificationProductUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'A product you are following has been updated with new features and improvements. Check it out!'**
  String get notificationProductUpdatedMessage;

  /// No description provided for @notificationDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'You have a new notification'**
  String get notificationDefaultMessage;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String timeMinutesAgo(Object minutes);

  /// No description provided for @timeMinutesAgoPlural.
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins ago'**
  String timeMinutesAgoPlural(Object minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr ago'**
  String timeHoursAgo(Object hours);

  /// No description provided for @timeHoursAgoPlural.
  ///
  /// In en, this message translates to:
  /// **'{hours} hrs ago'**
  String timeHoursAgoPlural(Object hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} day ago'**
  String timeDaysAgo(Object days);

  /// No description provided for @timeDaysAgoPlural.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String timeDaysAgoPlural(Object days);

  /// No description provided for @timeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks} week ago'**
  String timeWeeksAgo(Object weeks);

  /// No description provided for @timeWeeksAgoPlural.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String timeWeeksAgoPlural(Object weeks);

  /// No description provided for @timeDate.
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year}'**
  String timeDate(Object day, Object month, Object year);

  /// No description provided for @actionTrackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get actionTrackOrder;

  /// No description provided for @actionDownloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get actionDownloadInvoice;

  /// No description provided for @actionAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get actionAccept;

  /// No description provided for @actionDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get actionDecline;

  /// No description provided for @actionViewTeam.
  ///
  /// In en, this message translates to:
  /// **'View Team'**
  String get actionViewTeam;

  /// No description provided for @actionSeeChanges.
  ///
  /// In en, this message translates to:
  /// **'See Changes'**
  String get actionSeeChanges;

  /// No description provided for @actionUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get actionUpdateNow;

  /// No description provided for @actionViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get actionViewDetails;

  /// No description provided for @status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending;

  /// No description provided for @status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get status_rejected;

  /// No description provided for @status_suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get status_suspended;

  /// No description provided for @status_obsolete.
  ///
  /// In en, this message translates to:
  /// **'Obsolete'**
  String get status_obsolete;

  /// No description provided for @status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get status_active;

  /// No description provided for @inventory_view_title.
  ///
  /// In en, this message translates to:
  /// **'View Inventory'**
  String get inventory_view_title;

  /// No description provided for @inventory_view_description.
  ///
  /// In en, this message translates to:
  /// **'Can view current inventory levels and stock'**
  String get inventory_view_description;

  /// No description provided for @inventory_manage_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Inventory'**
  String get inventory_manage_title;

  /// No description provided for @inventory_manage_description.
  ///
  /// In en, this message translates to:
  /// **'Can update stock levels and manage products'**
  String get inventory_manage_description;

  /// No description provided for @orders_view_title.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get orders_view_title;

  /// No description provided for @orders_view_description.
  ///
  /// In en, this message translates to:
  /// **'Can view customer and supplier orders'**
  String get orders_view_description;

  /// No description provided for @orders_manage_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Orders'**
  String get orders_manage_title;

  /// No description provided for @orders_manage_description.
  ///
  /// In en, this message translates to:
  /// **'Can create, edit, and process orders'**
  String get orders_manage_description;

  /// No description provided for @personnel_view_title.
  ///
  /// In en, this message translates to:
  /// **'View Team'**
  String get personnel_view_title;

  /// No description provided for @personnel_view_description.
  ///
  /// In en, this message translates to:
  /// **'Can view other team members'**
  String get personnel_view_description;

  /// No description provided for @personnel_manage_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Team'**
  String get personnel_manage_title;

  /// No description provided for @personnel_manage_description.
  ///
  /// In en, this message translates to:
  /// **'Can add/remove team members and set permissions'**
  String get personnel_manage_description;

  /// No description provided for @manage_permissions.
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions'**
  String get manage_permissions;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save_permissions.
  ///
  /// In en, this message translates to:
  /// **'Save Permissions'**
  String get save_permissions;

  /// No description provided for @no_username.
  ///
  /// In en, this message translates to:
  /// **'No username'**
  String get no_username;

  /// No description provided for @category_inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get category_inventory;

  /// No description provided for @category_orders.
  ///
  /// In en, this message translates to:
  /// **'Order Management'**
  String get category_orders;

  /// No description provided for @category_personnel.
  ///
  /// In en, this message translates to:
  /// **'Personnel Management'**
  String get category_personnel;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get roleStaff;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get roleSupervisor;

  /// No description provided for @roleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get roleViewer;

  /// No description provided for @roleNoPrivileges.
  ///
  /// In en, this message translates to:
  /// **'No Privileges'**
  String get roleNoPrivileges;

  /// No description provided for @actionManagePermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get actionManagePermissions;

  /// No description provided for @actionNotify.
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get actionNotify;

  /// No description provided for @pendingInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'This user has a pending invitation.'**
  String get pendingInvitationMessage;

  /// No description provided for @actionResendInvite.
  ///
  /// In en, this message translates to:
  /// **'Resend Invitation'**
  String get actionResendInvite;

  /// No description provided for @actionCancelInvite.
  ///
  /// In en, this message translates to:
  /// **'Cancel Invitation'**
  String get actionCancelInvite;

  /// No description provided for @suppliersCountCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'{totalSuppliers,plural, =0{No locations}=1{1 location}other{{totalSuppliers} locations}} • {categoryCount,plural, =0{no category}=1{1 in category}other{{categoryCount} in category}}'**
  String suppliersCountCategoryCount(num categoryCount, num totalSuppliers);

  /// No description provided for @myBusinessesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Businesses'**
  String get myBusinessesTitle;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @filteredTxt.
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filteredTxt;

  /// No description provided for @noBusinessesFound.
  ///
  /// In en, this message translates to:
  /// **'No businesses found'**
  String get noBusinessesFound;

  /// No description provided for @adjustFilterBusinessHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get adjustFilterBusinessHint;

  /// No description provided for @addFirstBusinessHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first business to get started'**
  String get addFirstBusinessHint;

  /// No description provided for @addMemberText.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMemberText;

  /// No description provided for @addTeamMemberText.
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get addTeamMemberText;

  /// No description provided for @addUsersToManageText.
  ///
  /// In en, this message translates to:
  /// **'Add users to manage {supplierName}'**
  String addUsersToManageText(Object supplierName);

  /// No description provided for @scanQrCodeText.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCodeText;

  /// No description provided for @scanUserProfileQrText.
  ///
  /// In en, this message translates to:
  /// **'Scan user profile QR code'**
  String get scanUserProfileQrText;

  /// No description provided for @searchAndInviteText.
  ///
  /// In en, this message translates to:
  /// **'Search & Invite'**
  String get searchAndInviteText;

  /// No description provided for @searchAndInviteExistingUsersText.
  ///
  /// In en, this message translates to:
  /// **'Search and invite existing users'**
  String get searchAndInviteExistingUsersText;

  /// No description provided for @cancelText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelText;

  /// No description provided for @cancelInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Invitation'**
  String get cancelInvitationTitle;

  /// No description provided for @cancelInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'Cancel invitation? This cannot be undone.'**
  String get cancelInvitationMessage;

  /// No description provided for @cancelInvitationAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel Invitation'**
  String get cancelInvitationAction;

  /// No description provided for @removeTeamMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Team Member'**
  String get removeTeamMemberTitle;

  /// No description provided for @removeTeamMemberMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {userName} from {supplierName}?'**
  String removeTeamMemberMessage(Object supplierName, Object userName);

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @personnelManagement.
  ///
  /// In en, this message translates to:
  /// **'Personnel Management'**
  String get personnelManagement;

  /// No description provided for @privilegesUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Updated privileges for {userName}'**
  String privilegesUpdatedMessage(Object userName);

  /// No description provided for @privilegesUpdateFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to update privileges'**
  String get privilegesUpdateFailedMessage;

  /// No description provided for @privilegesUpdateError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating privileges'**
  String get privilegesUpdateError;

  /// No description provided for @barcodeText.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcodeText;

  /// No description provided for @barcodeCopiedText.
  ///
  /// In en, this message translates to:
  /// **'Barcode copied to clipboard'**
  String get barcodeCopiedText;

  /// No description provided for @sourceText.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceText;

  /// No description provided for @modelText.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelText;

  /// No description provided for @recentText.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentText;

  /// No description provided for @productDetailsText.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetailsText;

  /// No description provided for @createdText.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdText;

  /// No description provided for @lastUpdatedText.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdatedText;

  /// No description provided for @priceUpdatedText.
  ///
  /// In en, this message translates to:
  /// **'Price Updated'**
  String get priceUpdatedText;

  /// No description provided for @noProductDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Not Found'**
  String get noProductDataTitle;

  /// No description provided for @noProductDataDescription.
  ///
  /// In en, this message translates to:
  /// **'No product information found for this barcode. The product may be new or not in our database yet.'**
  String get noProductDataDescription;

  /// No description provided for @noProductDataHelp.
  ///
  /// In en, this message translates to:
  /// **'You can try scanning again or add the product details manually.'**
  String get noProductDataHelp;

  /// No description provided for @scanAgainText.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgainText;

  /// No description provided for @addManuallyText.
  ///
  /// In en, this message translates to:
  /// **'Add Product Manually'**
  String get addManuallyText;

  /// No description provided for @ownedText.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get ownedText;

  /// No description provided for @managedText.
  ///
  /// In en, this message translates to:
  /// **'Managed'**
  String get managedText;

  /// No description provided for @noOwnedBusinessesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Owned Businesses'**
  String get noOwnedBusinessesTitle;

  /// No description provided for @noOwnedBusinessesDescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t own any businesses yet'**
  String get noOwnedBusinessesDescription;

  /// No description provided for @noManagedBusinessesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Managed Businesses'**
  String get noManagedBusinessesTitle;

  /// No description provided for @noManagedBusinessesDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'re not managing any businesses'**
  String get noManagedBusinessesDescription;

  /// No description provided for @noBusinessesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Businesses'**
  String get noBusinessesTitle;

  /// No description provided for @noBusinessesDescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t own or manage any businesses yet'**
  String get noBusinessesDescription;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noResultsTitle;

  /// No description provided for @adjustSearchFiltersText.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get adjustSearchFiltersText;

  /// No description provided for @orderManagement.
  ///
  /// In en, this message translates to:
  /// **'Order Management'**
  String get orderManagement;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @selectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get selectSupplier;

  /// No description provided for @noOrderManagementPrivileges.
  ///
  /// In en, this message translates to:
  /// **'No order management privileges'**
  String get noOrderManagementPrivileges;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @noPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'No pending orders'**
  String get noPendingOrders;

  /// No description provided for @noProcessingOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders in processing'**
  String get noProcessingOrders;

  /// No description provided for @noCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'No completed orders'**
  String get noCompletedOrders;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @noOrdersFoundForStatus.
  ///
  /// In en, this message translates to:
  /// **'No orders found for this status'**
  String get noOrdersFoundForStatus;

  /// No description provided for @financeAndPricing.
  ///
  /// In en, this message translates to:
  /// **'Finance & Pricing'**
  String get financeAndPricing;

  /// No description provided for @manageInvoicesAndConfigurePricing.
  ///
  /// In en, this message translates to:
  /// **'Manage invoices & configure pricing'**
  String get manageInvoicesAndConfigurePricing;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @exportingData.
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get exportingData;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisQuarter.
  ///
  /// In en, this message translates to:
  /// **'This Quarter'**
  String get thisQuarter;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Costs'**
  String get pricing;

  /// No description provided for @newInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get newInvoice;

  /// No description provided for @selectSupplierFirstText.
  ///
  /// In en, this message translates to:
  /// **'Select a Supplier First'**
  String get selectSupplierFirstText;

  /// No description provided for @selectSupplierToViewText.
  ///
  /// In en, this message translates to:
  /// **'Please select a supplier to view their product inventory'**
  String get selectSupplierToViewText;

  /// No description provided for @noProductsText.
  ///
  /// In en, this message translates to:
  /// **'No Products Available'**
  String get noProductsText;

  /// No description provided for @noProductsFoundText.
  ///
  /// In en, this message translates to:
  /// **'No Products Found'**
  String get noProductsFoundText;

  /// No description provided for @tryDifferentSearchText.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or browse other suppliers'**
  String get tryDifferentSearchText;

  /// No description provided for @addFirstProductText.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to start selling'**
  String get addFirstProductText;

  /// No description provided for @quickTransactions.
  ///
  /// In en, this message translates to:
  /// **'Quick Transactions'**
  String get quickTransactions;

  /// No description provided for @barcodeScanningComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Barcode scanning coming soon'**
  String get barcodeScanningComingSoon;

  /// No description provided for @chooseStoreToViewProducts.
  ///
  /// In en, this message translates to:
  /// **'Choose a store to view products'**
  String get chooseStoreToViewProducts;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @noInventoryPrivilegesText.
  ///
  /// In en, this message translates to:
  /// **'Inventory Access Restricted'**
  String get noInventoryPrivilegesText;

  /// No description provided for @toCart.
  ///
  /// In en, this message translates to:
  /// **'to cart'**
  String get toCart;

  /// No description provided for @businesses.
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get businesses;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @pointOfSale.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get pointOfSale;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @createNewOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get createNewOrder;

  /// No description provided for @openCart.
  ///
  /// In en, this message translates to:
  /// **'Open Cart'**
  String get openCart;

  /// No description provided for @createNewInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createNewInvoice;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @accessRequired.
  ///
  /// In en, this message translates to:
  /// **'Access Required'**
  String get accessRequired;

  /// No description provided for @pleaseLoginToAccessDashboard.
  ///
  /// In en, this message translates to:
  /// **'Please log in to access the dashboard.'**
  String get pleaseLoginToAccessDashboard;

  /// No description provided for @needBusinessAssignment.
  ///
  /// In en, this message translates to:
  /// **'You need to be assigned to a business to access management features.'**
  String get needBusinessAssignment;

  /// No description provided for @contactAdminOrJoinTeam.
  ///
  /// In en, this message translates to:
  /// **'Contact your administrator or join a business team.'**
  String get contactAdminOrJoinTeam;

  /// No description provided for @checkAccessStatus.
  ///
  /// In en, this message translates to:
  /// **'Check Access Status'**
  String get checkAccessStatus;

  /// No description provided for @viewPendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'View Pending Invitations'**
  String get viewPendingInvitations;

  /// No description provided for @pendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvitations;

  /// No description provided for @noPendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get noPendingInvitations;

  /// No description provided for @unknownBusiness.
  ///
  /// In en, this message translates to:
  /// **'Unknown Business'**
  String get unknownBusiness;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @invitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted!'**
  String get invitationAccepted;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined.'**
  String get invitationDeclined;

  /// No description provided for @noRoleAssigned.
  ///
  /// In en, this message translates to:
  /// **'No role assigned'**
  String get noRoleAssigned;

  /// No description provided for @noAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'No Analytics Data'**
  String get noAnalyticsData;

  /// No description provided for @generateInvoicesToSeeAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Generate invoices to see analytics data'**
  String get generateInvoicesToSeeAnalytics;

  /// No description provided for @financialOverview.
  ///
  /// In en, this message translates to:
  /// **'Financial Overview'**
  String get financialOverview;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @growthRate.
  ///
  /// In en, this message translates to:
  /// **'Growth Rate'**
  String get growthRate;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @averageOrder.
  ///
  /// In en, this message translates to:
  /// **'Average Order'**
  String get averageOrder;

  /// No description provided for @taxCollected.
  ///
  /// In en, this message translates to:
  /// **'Tax Collected'**
  String get taxCollected;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @last5Transactions.
  ///
  /// In en, this message translates to:
  /// **'Last 5 transactions'**
  String get last5Transactions;

  /// No description provided for @viewAllTransactions.
  ///
  /// In en, this message translates to:
  /// **'View All Transactions'**
  String get viewAllTransactions;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// Invoice label
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// Item count label
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// Share button label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Download button label
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Invoices Yet'**
  String get noInvoicesYet;

  /// Empty state description
  ///
  /// In en, this message translates to:
  /// **'Your invoices will appear here once you complete sales'**
  String get noInvoicesDescription;

  /// Create invoice button
  ///
  /// In en, this message translates to:
  /// **'Create First Invoice'**
  String get createFirstInvoice;

  /// Loading state message
  ///
  /// In en, this message translates to:
  /// **'Loading invoices...'**
  String get loadingInvoices;

  /// Payment method - card
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// Payment method - cash
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// Payment method - bank transfer
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// Payment method - mobile payment
  ///
  /// In en, this message translates to:
  /// **'Mobile Payment'**
  String get mobilePayment;

  /// Snackbar message when sharing
  ///
  /// In en, this message translates to:
  /// **'Sharing invoice'**
  String get sharingInvoice;

  /// Snackbar message when downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading invoice'**
  String get downloadingInvoice;

  /// Invoice details title
  ///
  /// In en, this message translates to:
  /// **'Invoice Details'**
  String get invoiceDetails;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get currencySymbol;

  /// No description provided for @accessRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Refreshed access'**
  String get accessRefreshed;

  /// No description provided for @manageSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Manage Suppliers'**
  String get manageSuppliers;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add first product'**
  String get addFirstProduct;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// No description provided for @serviceDiscount.
  ///
  /// In en, this message translates to:
  /// **'{percent}% {label}'**
  String serviceDiscount(Object label, Object percent);

  /// No description provided for @serviceDiscountOff.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get serviceDiscountOff;

  /// No description provided for @servicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'available'**
  String get servicesAvailable;

  /// No description provided for @loadingServices.
  ///
  /// In en, this message translates to:
  /// **'Loading services...'**
  String get loadingServices;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get noServicesFound;

  /// No description provided for @noServicesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first service to start offering healthcare services to patients.'**
  String get noServicesDescription;

  /// No description provided for @proTip.
  ///
  /// In en, this message translates to:
  /// **'Pro Tip'**
  String get proTip;

  /// No description provided for @addServicesToManage.
  ///
  /// In en, this message translates to:
  /// **'Add services to manage appointments, pricing, and resource allocation efficiently.'**
  String get addServicesToManage;

  /// No description provided for @status_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get status_inactive;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @searchServices.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get searchServices;

  /// No description provided for @profitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin'**
  String get profitMargin;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get serviceDescription;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @deletedAt.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deletedAt;

  /// No description provided for @basePrice.
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get basePrice;

  /// No description provided for @finalPrice.
  ///
  /// In en, this message translates to:
  /// **'Final Price'**
  String get finalPrice;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @discountApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount applied from base price'**
  String get discountApplied;

  /// No description provided for @resourceRequirements.
  ///
  /// In en, this message translates to:
  /// **'Resource Requirements'**
  String get resourceRequirements;

  /// No description provided for @staffRequirements.
  ///
  /// In en, this message translates to:
  /// **'Staff Requirements'**
  String get staffRequirements;

  /// No description provided for @totalResourceCost.
  ///
  /// In en, this message translates to:
  /// **'Total Resource Cost'**
  String get totalResourceCost;

  /// No description provided for @totalStaffCost.
  ///
  /// In en, this message translates to:
  /// **'Total Staff Cost'**
  String get totalStaffCost;

  /// No description provided for @costSummary.
  ///
  /// In en, this message translates to:
  /// **'Cost Summary'**
  String get costSummary;

  /// No description provided for @resourceCost.
  ///
  /// In en, this message translates to:
  /// **'Resource Cost'**
  String get resourceCost;

  /// No description provided for @staffCost.
  ///
  /// In en, this message translates to:
  /// **'Staff Cost'**
  String get staffCost;

  /// No description provided for @totalServiceCost.
  ///
  /// In en, this message translates to:
  /// **'Total Service Cost'**
  String get totalServiceCost;

  /// No description provided for @servicePrice.
  ///
  /// In en, this message translates to:
  /// **'Service Price'**
  String get servicePrice;

  /// No description provided for @businessOperations.
  ///
  /// In en, this message translates to:
  /// **'Business Operations'**
  String get businessOperations;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// No description provided for @noBusinessOperations.
  ///
  /// In en, this message translates to:
  /// **'No Business Operations'**
  String get noBusinessOperations;

  /// No description provided for @generateOperationsToSeeData.
  ///
  /// In en, this message translates to:
  /// **'Generate business operations to see detailed analytics and transaction data'**
  String get generateOperationsToSeeData;

  /// No description provided for @exportOperations.
  ///
  /// In en, this message translates to:
  /// **'Export Operations'**
  String get exportOperations;

  /// No description provided for @viewAllBusinessTransactions.
  ///
  /// In en, this message translates to:
  /// **'View all business transactions and operations'**
  String get viewAllBusinessTransactions;

  /// No description provided for @topSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Top Suppliers'**
  String get topSuppliers;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @carts.
  ///
  /// In en, this message translates to:
  /// **'Carts'**
  String get carts;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @byStatus.
  ///
  /// In en, this message translates to:
  /// **'By Status'**
  String get byStatus;

  /// No description provided for @bySource.
  ///
  /// In en, this message translates to:
  /// **'By Source'**
  String get bySource;

  /// No description provided for @operationDetails.
  ///
  /// In en, this message translates to:
  /// **'Operation Details'**
  String get operationDetails;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @cartBasedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Cart-based Transaction'**
  String get cartBasedTransaction;

  /// No description provided for @orderBasedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Order-based Transaction'**
  String get orderBasedTransaction;

  /// No description provided for @operationSummary.
  ///
  /// In en, this message translates to:
  /// **'Operation Summary'**
  String get operationSummary;

  /// No description provided for @operationId.
  ///
  /// In en, this message translates to:
  /// **'Operation ID'**
  String get operationId;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get seller;

  /// No description provided for @cartBased.
  ///
  /// In en, this message translates to:
  /// **'Cart-based'**
  String get cartBased;

  /// No description provided for @orderBased.
  ///
  /// In en, this message translates to:
  /// **'Order-based'**
  String get orderBased;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @totalDeposited.
  ///
  /// In en, this message translates to:
  /// **'Total Deposited'**
  String get totalDeposited;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// No description provided for @processPayment.
  ///
  /// In en, this message translates to:
  /// **'Process Payment'**
  String get processPayment;

  /// No description provided for @sendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send Reminder'**
  String get sendReminder;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @sharingOperation.
  ///
  /// In en, this message translates to:
  /// **'Sharing operation...'**
  String get sharingOperation;

  /// No description provided for @printingOperation.
  ///
  /// In en, this message translates to:
  /// **'Printing operation...'**
  String get printingOperation;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPayment;

  /// No description provided for @sendingReminder.
  ///
  /// In en, this message translates to:
  /// **'Sending reminder...'**
  String get sendingReminder;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @itemsWillBeLoadedFromServer.
  ///
  /// In en, this message translates to:
  /// **'Items will be loaded from the server'**
  String get itemsWillBeLoadedFromServer;

  /// No description provided for @loadItems.
  ///
  /// In en, this message translates to:
  /// **'Load Items'**
  String get loadItems;

  /// No description provided for @loadingItems.
  ///
  /// In en, this message translates to:
  /// **'Loading items...'**
  String get loadingItems;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @fullyPaid.
  ///
  /// In en, this message translates to:
  /// **'Fully Paid'**
  String get fullyPaid;

  /// No description provided for @partiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get partiallyPaid;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @noSuppliersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No suppliers available'**
  String get noSuppliersAvailable;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @browseAndSelectServices.
  ///
  /// In en, this message translates to:
  /// **'Browse and select services'**
  String get browseAndSelectServices;

  /// No description provided for @noServicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No services available'**
  String get noServicesAvailable;

  /// No description provided for @servicesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Services will appear here when available'**
  String get servicesWillAppearHere;

  /// No description provided for @loadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Loading products...'**
  String get loadingProducts;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailable;

  /// No description provided for @preparingServiceCatalog.
  ///
  /// In en, this message translates to:
  /// **'Preparing your service catalog'**
  String get preparingServiceCatalog;

  /// No description provided for @refreshServices.
  ///
  /// In en, this message translates to:
  /// **'Refresh Services'**
  String get refreshServices;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @operationType.
  ///
  /// In en, this message translates to:
  /// **'Operation Type'**
  String get operationType;

  /// No description provided for @invoiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Invoice Status'**
  String get invoiceStatus;

  /// No description provided for @deposited.
  ///
  /// In en, this message translates to:
  /// **'Deposited'**
  String get deposited;
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
