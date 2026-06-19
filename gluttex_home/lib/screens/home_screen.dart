// import 'dart:log';

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chef/screens/recipe_catalog_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:gluttex_home/screens/SettingsScreen.dart';
import 'package:gluttex_home/screens/components/notification_button.dart';
import 'package:gluttex_home/screens/components/notifications_panel.dart';
import 'package:gluttex_home/screens/profile_screen.dart';
import 'package:event/user_change_notifier.dart';
import 'package:event/product_change_notifier.dart';
import 'package:store_geo/screens/suppliers_map_screen.dart';
import 'package:gluttex_play/screens/game_catalog.dart';
import 'package:product_catalog/screens/product_catalog_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Changed from SingleTickerProviderStateMixin

  late final AnimationController _animationController;
  ProductNotifier? _productNotifier;
  // late final AnimationController _notificationController;

  int _selectedIndex = 0;
  int _animationCount = 0;
  int _notificationCount = 5; // Example count - replace with your actual data
  late Animation<double> _scaleAnimation;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ProductCatalogScreen(),
      const SuppliersMapScreen(),
      const RecipeCatalogScreen(),
      GameSelectionScreen(),
      const ProfileScreen(),
    ];
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 1.2),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0),
          weight: 50,
        ),
      ],
    ).animate(_animationController);

    // Initialize productNotifier after initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productNotifier = context.read<ProductNotifier>();
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Uncomment this line
    // _notificationController.dispose();
    super.dispose();
  }

  void _startIconAnimation() {
    if (_selectedIndex != GluttexPageIndex.profile) return;

    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        if (!mounted) return;
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
    final productNotifier = context.read<ProductNotifier>();

    final currentCategory = productNotifier.currentCategory;
    log('Current Category: $currentCategory');

    productNotifier.fetchProducts(categoryId: currentCategory, reset: true);
  }

  void _handleProfilePage() {
    _animationCount = 0;
    _startIconAnimation();
  }

  void _handleSuppliersPage() {
    context.read<SupplierChangeNotifier>().fetchOrganisations();
  }

  // Replace the _buildNotificationButton method:
  Widget _buildNotificationButton() {
    return NotificationButton(
      onPressed: _showNotifications,
      iconColor: Theme.of(context).colorScheme.onSurface,
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const NotificationsPanel(),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount:
          _notificationCount.clamp(0, 5).toInt(), // Show max 5 in preview
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildNotificationItem(index),
    );
  }

  Widget _buildNotificationItem(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Handle notification tap
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(index, colorScheme),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNotificationIcon(index),
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getNotificationTitle(index),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have a new notification from the system',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2 hours ago',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(int index, ColorScheme colorScheme) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  IconData _getNotificationIcon(int index) {
    final icons = [
      Icons.inventory_2_rounded,
      Icons.local_offer_rounded,
      Icons.person_add_rounded,
      Icons.security_rounded,
      Icons.event_available_rounded,
    ];
    return icons[index % icons.length];
  }

  String _getNotificationTitle(int index) {
    final titles = [
      'New Product',
      'Special Offer',
      'Team Member',
      'Security Alert',
      'Event Reminder',
    ];
    return titles[index % titles.length];
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
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
          // _buildBannerAd(), // Banner ad above navigation
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(backgroundColor),
    );
  }

  AppBar _buildAppBar(ThemeData theme, Color backgroundColor) {
    return AppBar(
      title: Text(_getTitle(_selectedIndex)),
      actions: [
        _buildNotificationButton(),
        _buildSettingsButton() ?? Container(),
      ],
      backgroundColor: backgroundColor,
    );
  }

  Widget? _buildSettingsButton() {
    if (_selectedIndex != GluttexPageIndex.profile)
      return const SizedBox.shrink();

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
        appUser.app_user_image_url!,
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
