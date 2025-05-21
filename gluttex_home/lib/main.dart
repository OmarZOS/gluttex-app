import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Services/AuthService.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/business/services/OrderService.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_home/gluttex_router.dart';
import 'package:gluttex_impl_app/gluttex_impl_app.dart';
import 'package:gluttex_impl_app/gluttex_impl_auth.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_impl_business/cart_change_notifier.dart';
import 'package:gluttex_impl_business/gluttex_impl_order.dart';
import 'package:gluttex_impl_business/gluttex_impl_product.dart';
import 'package:gluttex_impl_business/gluttex_impl_recipe.dart';
import 'package:gluttex_impl_business/gluttex_impl_supplier.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:gluttex_impl_business/supplier_change_notifier.dart';
import 'package:gluttex_impl_mediation/gluttex_impl_mediation.dart';
import 'package:gluttex_impl_mediation/preferenceChangeNotifier.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void setupLocator() {
  // Register your services or dependencies here
  GluttexLocator.registerSingletonService<StorageService>(StorageServiceImpl());
  GluttexLocator.registerSingletonService<AppUserService>(AppUserServiceImpl());
  GluttexLocator.registerSingletonService<RecipeService>(RecipeServiceImpl());
  GluttexLocator.registerSingletonService<SupplierService>(
      SupplierServiceImpl());
  GluttexLocator.registerSingletonService<ProductService>(ProductServiceImpl());
  GluttexLocator.registerSingletonService<OrderService>(OrderServiceImpl());
  GluttexLocator.registerSingletonService<AuthService>(AuthServiceImpl());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();
  await localeProvider.getThemePreference();
  // await localeProvider.setLanguagePreference("ar");

  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GluttexApp(localeProvider));
}

class GluttexApp extends StatelessWidget {
  final LocaleProvider localeProvider;

  const GluttexApp(this.localeProvider, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductNotifier>(
            create: (_) => ProductNotifier()),
        ChangeNotifierProvider<RecipeNotifier>(create: (_) => RecipeNotifier()),
        ChangeNotifierProvider<AppUserNotifier>(
            create: (_) => AppUserNotifier()),
        ChangeNotifierProvider<CartChangeNotifier>(
            create: (_) => CartChangeNotifier()),
        ChangeNotifierProvider<SupplierChangeNotifier>(
            create: (_) => SupplierChangeNotifier()),
        ChangeNotifierProvider<LocaleProvider>(create: (_) => localeProvider),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('ar'), // Arabic
              Locale('fr'), // French
              Locale('en'), // English
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // home: const HomePage(),
            navigatorKey: globalNavigatorKey,
            onGenerateRoute: AppRouter.generateRoute,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  brightness: Brightness.light, seedColor: Colors.green),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  brightness: Brightness.dark, seedColor: Colors.lightGreen),
            ),
            themeMode: localeProvider.themeMode,
          );
        },
      ),
    );
  }
}
