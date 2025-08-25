import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_catalog_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_home/screens/SettingsScreen.dart';
import 'package:gluttex_home/screens/profile_screen.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_localiser/screens/suppliers_map_screen.dart';
import 'package:gluttex_play/screens/game_catalog.dart';
import 'package:medicom_catalog/screens/product_catalog_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _animationCount = 0;
  late AnimationController _controller;
  late ProductNotifier provider;

  @override
  void initState() {
    provider = Provider.of<ProductNotifier>(context, listen: false);

    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Start the animation sequence
    // _startIconAnimation();
  }

  void _startIconAnimation() {
    if (_selectedIndex != GluttexPageIndex.profile)
      return; // Only animate in profile
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        _animationCount++;
        if (_animationCount < 2 && _selectedIndex == GluttexPageIndex.profile) {
          _startIconAnimation(); // repeat only while on profile
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static final List<Widget> _pages = <Widget>[
    const ProductCatalogScreen(),
    const SuppliersMapScreen(),
    const RecipeCatalogScreen(),
    // CeliacScreen(),
    GameSelectionScreen(),
    const ProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == GluttexPageIndex.catalog) {
        final currentCategory = provider.currentCategory;
        log('Current Category: $currentCategory');
        provider.fetchProducts(categoryId: currentCategory, reset: true);
      }
      if (_selectedIndex == GluttexPageIndex.profile) {
        _animationCount = 0;
        _startIconAnimation();
      }
      if (_selectedIndex == GluttexPageIndex.suppliers) {
        Provider.of<SupplierChangeNotifier>(context, listen: false)
            .fetchOrganisations();
      }
    });
  }

  String _getTitle(selectedIndex) {
    switch (selectedIndex) {
      case GluttexPageIndex.catalog:
        return AppLocalizations.of(context)!.productsText;
      case GluttexPageIndex.suppliers:
        return AppLocalizations.of(context)!.providersText;
      case GluttexPageIndex.recipes:
        return AppLocalizations.of(context)!.recipesText;
      case GluttexPageIndex.games:
        return AppLocalizations.of(context)!.gamesText;
      case GluttexPageIndex.profile:
        return AppLocalizations.of(context)!.profileText;
      default:
        return '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = Provider.of<AppUserNotifier>(context);
    if (notifier.appUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appUser = Provider.of<AppUserNotifier>(context).appUser;
    final diplayName = '${appUser?.personFirstName} ${appUser?.personLastName}';
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        actions: [
          if (_selectedIndex == GluttexPageIndex.profile)
            RotationTransition(
              turns: Tween(begin: -0.05, end: 0.05)
                  .chain(CurveTween(curve: Curves.easeInOut))
                  .animate(_controller),
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _navigateToSettings(context),
              ),
            ),
        ],
        backgroundColor: isDarkMode
            ? GluttexConstants.backgroundDarkColor
            : GluttexConstants.backgroundColor,

        // actions: [
        //   IconButton(
        //       onPressed: () async {
        //         Navigator.push(context, MaterialPageRoute(builder: (context) {
        //           // Provider.of<AppUserNotifier>(context, listen: false)
        //           //     .fetchAppUser('1');
        //           return const ProfileScreen();
        //         }));
        //       },
        //       icon: const Icon(CupertinoIcons.profile_circled))
        // ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.cube_box_fill),
              label: AppLocalizations.of(context)!.productsText,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? GluttexConstants.backgroundColor
                  : GluttexConstants.backgroundDarkColor),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store_sharp),
            label: AppLocalizations.of(context)!.providersText,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? GluttexConstants.backgroundColor
                : GluttexConstants.backgroundDarkColor,
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.restaurant_menu_outlined),
              label: AppLocalizations.of(context)!.recipesText,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? GluttexConstants.backgroundColor
                  : GluttexConstants.backgroundDarkColor),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.gamecontroller_alt_fill),
            label: AppLocalizations.of(context)!.gamesText,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? GluttexConstants.backgroundColor
                : GluttexConstants.backgroundDarkColor,
          ),
          BottomNavigationBarItem(
              icon: appUser?.id_app_user != 0 &&
                      appUser?.app_user_image_url != null
                  ? ClipOval(
                      child: Image.network(
                        GluttexConstants.fsBaseUrl +
                            (appUser?.app_user_image_url ?? ""),
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 24,
                            width: 24,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 24,
                            // color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.person, size: 24),
                            ),
                          );
                        },
                      ),
                    )
                  : const Icon(size: 24.0, CupertinoIcons.profile_circled),
              label: ((appUser?.id_app_user ?? 0) == 0 || diplayName == " ")
                  ? AppLocalizations.of(context)!.profileText
                  : (diplayName),
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? GluttexConstants.backgroundColor
                  : GluttexConstants.backgroundDarkColor),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SettingsScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
