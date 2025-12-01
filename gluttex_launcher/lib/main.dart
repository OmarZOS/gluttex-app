import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/app/Services/NotificationService.dart';
import 'package:gluttex_event/assistant_change_notifier.dart';
import 'package:gluttex_event/notification_notifier.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/supplier_dashboard_provider.dart';
import 'package:gluttex_impl_app/gluttex_impl_notification.dart';
import 'package:gluttex_io/GluttexImageImpl.dart';
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
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:gluttex_impl_business/gluttex_impl_order.dart';
import 'package:gluttex_impl_business/gluttex_impl_product.dart';
import 'package:gluttex_impl_business/gluttex_impl_recipe.dart';
import 'package:gluttex_impl_business/gluttex_impl_supplier.dart';
import 'package:gluttex_event/recipe_change_notifier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_impl_mediation/gluttex_impl_mediation.dart';
import 'package:gluttex_event/preferenceChangeNotifier.dart';
import 'package:gluttex_login/screens/web_view.dart';
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
  GluttexLocator.registerSingletonService<NotificationService>(
      GluttexImplNotification());
  GluttexLocator.registerSingletonService<ProductService>(ProductServiceImpl());
  GluttexLocator.registerSingletonService<OrderService>(OrderServiceImpl());
  GluttexLocator.registerSingletonService<AuthService>(AuthServiceImpl());
  GluttexLocator.registerFactory<GluttexImage>(() => GluttexImageImpl());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();
  await localeProvider.getThemePreference();
  // await localeProvider.setLanguagePreference("ar");

  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize GoogleLoginManager
  GoogleLoginManager.initialize();
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
        ChangeNotifierProvider<AssistantNotifier>(
            create: (_) => AssistantNotifier()),
        ChangeNotifierProvider<SupplierChangeNotifier>(
            create: (_) => SupplierChangeNotifier()),
        ChangeNotifierProvider<SupplierDashboardProvider>(
            create: (_) => SupplierDashboardProvider()),
        ChangeNotifierProvider<NotificationNotifier>(
            create: (_) => NotificationNotifier()),
        ChangeNotifierProvider<PersonnelNotifier>(
            create: (_) => PersonnelNotifier()),
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
                seedColor: const Color(0xFF2ECC71),
                primary: const Color(0xFF2ECC71),
                secondary: const Color(0xFF3498DB), // Complementary blue
                tertiary: const Color(0xFFE74C3C), // Accent red
                onPrimaryFixed: Colors.white,
                // background: const Color(0xFFF8F9FA), // Light background
                // onBackground: const Color(0xFF212121), // Main text color
                // surface: Colors.white, // Card surfaces
                onPrimary: Colors.white, // Text on primary
                onSecondary: Colors.white, // Text on secondary
                onSurface: const Color(0xFF212121), // Text on surfaces
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2ECC71),
                primary: const Color(0xFF2ECC71), // Your primary green
                primaryContainer: const Color(0xFF27AE60), // Darker green
                secondary: const Color(0xFF3498DB), // Blue
                secondaryContainer: const Color(0xFF2980B9), // Darker blue
                tertiary: const Color(0xFFE74C3C), // Red accent
                background: const Color(0xFF121212), // Dark background
                surface: const Color(0xFF1E1E1E), // Card surfaces
                surfaceVariant: const Color(0xFF2D2D2D), // Lighter surfaces
                onPrimary: Colors.white,
                onPrimaryFixed: const Color(0xFF1E1E1E),
                onSecondary: Colors.white,
                onBackground: Colors.white.withOpacity(0.87),
                onSurface: Colors.white.withOpacity(0.87),
                onSurfaceVariant: Colors.white.withOpacity(0.6),
                outline: const Color(0xFF404040), // Borders
                outlineVariant: const Color(0xFF2D2D2D), // Subtle borders
                brightness: Brightness.dark,
              ),
            ),
            themeMode: localeProvider.themeMode,
          );
        },
      ),
    );
  }
}
