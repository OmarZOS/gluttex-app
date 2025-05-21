import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_catalog_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_home/screens/profile_screen.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_localiser/screens/sliding_suppliers_widget.dart';
import 'package:gluttex_medical/screens/informations_screen.dart';
import 'package:gluttex_play/screens/game_catalog.dart';
import 'package:medicom_catalog/screens/catalog_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const CatalogScreen(),
    const SlidingSuppliersWidget(),
    const RecipeCatalogScreen(),
    // CeliacScreen(),
    GameSelectionScreen(),
    const ProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTitle(selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return AppLocalizations.of(context)!.productsText;
      case 1:
        return AppLocalizations.of(context)!.providersText;
      case 2:
        return AppLocalizations.of(context)!.recipesText;
      case 3:
        return AppLocalizations.of(context)!.gamesText;
      case 4:
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        backgroundColor: isDarkMode
            ? // Darker green shades
            const Color(0xFF186A3B)
            : const Color(0xFF2ECC71),

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
        unselectedItemColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Theme.of(context).colorScheme.surface,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.cube_box_fill),
            label: AppLocalizations.of(context)!.productsText,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? const Color.fromARGB(255, 67, 125, 133) // Light teal
                : const Color(0xFF4DB6AC), // Dark muted teal
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store_sharp),
            label: AppLocalizations.of(context)!.providersText,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? const Color.fromARGB(255, 70, 99, 138) // Light blue
                : const Color(0xFF5C6BC0), // Dark periwinkle
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu_outlined),
            label: AppLocalizations.of(context)!.recipesText,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? const Color.fromARGB(255, 107, 63, 124) // Light purple
                : const Color(0xFFAB47BC), // Dark lavender
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.gamecontroller_alt_fill),
            label: AppLocalizations.of(context)!.gamesText,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? const Color.fromARGB(255, 67, 72, 133) // Light navy
                : const Color(0xFF3949AB), // Dark softer navy
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.profile_circled),
            label: AppLocalizations.of(context)!.profileText,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? const Color.fromARGB(255, 136, 68, 102) // Light mauve
                : const Color(0xFFEC407A), // Dark soft pink
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
