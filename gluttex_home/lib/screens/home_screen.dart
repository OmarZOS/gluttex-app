import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_catalog_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_home/screens/profile_screen.dart';
import 'package:gluttex_localiser/screens/sliding_suppliers_widget.dart';
import 'package:gluttex_medical/screens/informations_screen.dart';
import 'package:gluttex_play/screens/game_catalog.dart';
import 'package:medicom_catalog/screens/catalog_screen.dart';

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
    const HealthInfoScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  // Provider.of<AppUserNotifier>(context, listen: false)
                  //     .fetchAppUser('1');
                  return const ProfileScreen();
                }));
              },
              icon: const Icon(CupertinoIcons.profile_circled))
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orangeAccent,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 67, 125, 133),
            icon: const Icon(CupertinoIcons.cube_box_fill),
            label: AppLocalizations.of(context)!.productsText,
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 70, 99, 138),
            icon: const Icon(Icons.store_sharp),
            label: AppLocalizations.of(context)!.providersText,
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 107, 63, 124),
            icon: const Icon(Icons.restaurant_menu_outlined),
            label: AppLocalizations.of(context)!.recipesText,
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 67, 72, 133),
            icon: const Icon(CupertinoIcons.gamecontroller_alt_fill),
            label: AppLocalizations.of(context)!.gamesText,
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color.fromARGB(255, 136, 68, 102),
            icon: const Icon(Icons.health_and_safety),
            label: AppLocalizations.of(context)!.healthText,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
