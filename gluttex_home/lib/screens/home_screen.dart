import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_catalog_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 600);

  late final AnimationController _animationController;
  late final ProductNotifier _productNotifier;

  int _selectedIndex = 0;
  int _animationCount = 0;

  static final List<Widget> _pages = <Widget>[
    const ProductCatalogScreen(),
    const SuppliersMapScreen(),
    const RecipeCatalogScreen(),
    GameSelectionScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _productNotifier = context.read<ProductNotifier>();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startIconAnimation() {
    if (_selectedIndex != GluttexPageIndex.profile) return;

    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        _animationCount++;
        if (_animationCount < 2 && _selectedIndex == GluttexPageIndex.profile) {
          _startIconAnimation();
        }
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _handlePageSpecificLogic(index);
    });
  }

  void _handlePageSpecificLogic(int index) {
    switch (index) {
      case GluttexPageIndex.catalog:
        _handleCatalogPage();
        break;
      case GluttexPageIndex.profile:
        _handleProfilePage();
        break;
      case GluttexPageIndex.suppliers:
        _handleSuppliersPage();
        break;
    }
  }

  void _handleCatalogPage() {
    final currentCategory = _productNotifier.currentCategory;
    log('Current Category: $currentCategory');
    _productNotifier.fetchProducts(categoryId: currentCategory, reset: true);
  }

  void _handleProfilePage() {
    _animationCount = 0;
    _startIconAnimation();
  }

  void _handleSuppliersPage() {
    context.read<SupplierChangeNotifier>().fetchOrganisations();
  }

  String _getTitle(int selectedIndex) {
    final localizations = AppLocalizations.of(context);

    switch (selectedIndex) {
      case GluttexPageIndex.catalog:
        return localizations!.productsText;
      case GluttexPageIndex.suppliers:
        return localizations!.providersText;
      case GluttexPageIndex.recipes:
        return localizations!.recipesText;
      case GluttexPageIndex.games:
        return localizations!.gamesText;
      case GluttexPageIndex.profile:
        return localizations!.profileText;
      default:
        return '';
    }
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SettingsScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? GluttexConstants.backgroundDarkColor
        : GluttexConstants.backgroundColor;

    return Scaffold(
      appBar: _buildAppBar(theme, backgroundColor),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(backgroundColor),
    );
  }

  AppBar _buildAppBar(ThemeData theme, Color backgroundColor) {
    return AppBar(
      title: Text(_getTitle(_selectedIndex)),
      actions: [
        _buildSettingsButton() ?? Container(),
      ],
      backgroundColor: backgroundColor,
    );
  }

  Widget? _buildSettingsButton() {
    if (_selectedIndex != GluttexPageIndex.profile) return null;

    return RotationTransition(
      turns: Tween(begin: -0.05, end: 0.05)
          .chain(CurveTween(curve: Curves.easeInOut))
          .animate(_animationController),
      child: IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => _navigateToSettings(context),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(Color backgroundColor) {
    return BottomNavigationBar(
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      selectedItemColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: backgroundColor,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: _buildNavigationItems(),
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    final localizations = AppLocalizations.of(context)!;
    final appUser = context.watch<AppUserNotifier>().appUser;
    final displayName =
        '${appUser?.personFirstName} ${appUser?.personLastName}'.trim();
    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? GluttexConstants.backgroundColor
        : GluttexConstants.backgroundDarkColor;

    return [
      _buildNavigationItem(
        icon: const Icon(CupertinoIcons.cube_box_fill),
        label: localizations.productsText,
        backgroundColor: backgroundColor,
      ),
      _buildNavigationItem(
        icon: const Icon(Icons.store_sharp),
        label: localizations.providersText,
        backgroundColor: backgroundColor,
      ),
      _buildNavigationItem(
        icon: const Icon(Icons.restaurant_menu_outlined),
        label: localizations.recipesText,
        backgroundColor: backgroundColor,
      ),
      _buildNavigationItem(
        icon: const Icon(CupertinoIcons.gamecontroller_alt_fill),
        label: localizations.gamesText,
        backgroundColor: backgroundColor,
      ),
      _buildProfileNavigationItem(
          appUser, displayName, localizations, backgroundColor),
    ];
  }

  BottomNavigationBarItem _buildNavigationItem({
    required Widget icon,
    required String label,
    required Color backgroundColor,
  }) {
    return BottomNavigationBarItem(
      icon: icon,
      label: label,
      backgroundColor: backgroundColor,
    );
  }

  BottomNavigationBarItem _buildProfileNavigationItem(
    AppUser? appUser,
    String displayName,
    AppLocalizations localizations,
    Color backgroundColor,
  ) {
    final isGuestUser = (appUser?.id_app_user ?? 0) == 0;
    final profileLabel = isGuestUser || displayName.isEmpty
        ? localizations.profileText
        : displayName;

    return BottomNavigationBarItem(
      icon: _buildProfileIcon(appUser),
      label: profileLabel,
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildProfileIcon(AppUser? appUser) {
    final hasProfileImage = appUser?.id_app_user != 0 &&
        appUser?.app_user_image_url != null &&
        appUser!.app_user_image_url!.isNotEmpty;

    if (!hasProfileImage) {
      return const Icon(size: 24.0, CupertinoIcons.profile_circled);
    }

    return ClipOval(
      child: Image.network(
        appUser!.app_user_image_url!,
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildProfileLoadingIndicator(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildProfileErrorWidget();
        },
      ),
    );
  }

  Widget _buildProfileLoadingIndicator(ImageChunkEvent loadingProgress) {
    return SizedBox(
      height: 24,
      width: 24,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  (loadingProgress.expectedTotalBytes ?? 1)
              : null,
        ),
      ),
    );
  }

  Widget _buildProfileErrorWidget() {
    return const SizedBox(
      height: 24,
      child: Center(
        child: Icon(Icons.person, size: 24),
      ),
    );
  }
}
