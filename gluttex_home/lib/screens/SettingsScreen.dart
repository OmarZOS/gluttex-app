import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_impl_mediation/preferenceChangeNotifier.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    // final themeProvider = Provider.of<ThemeNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: ListView(
        children: [
          Padding(padding: EdgeInsets.all(16.0)),
          // Language Selection
          ListTile(
            title: Text(AppLocalizations.of(context)!.languageText),
            // subtitle: Text(AppLocalizations.of(context)!
            //     .currentLanguage(localeProvider.languagePreference ?? "")),
            trailing: const Icon(Icons.language),
            onTap: () {
              _showLanguageDialog(context, localeProvider);
            },
          ),

          const Padding(padding: EdgeInsets.all(8.0)),
          // Dark Mode Toggle
          ListTile(
            title: Text(AppLocalizations.of(context)!.darkModeText),
            trailing: Consumer<LocaleProvider>(
              builder: (context, mylocaleProvider, _) {
                if (mylocaleProvider.isDarkMode == null) {
                  final brightness = MediaQuery.of(context).platformBrightness;
                  mylocaleProvider.isDarkMode = brightness == Brightness.dark;
                }
                return Switch(
                  value: mylocaleProvider.isDarkMode ?? true,
                  onChanged: (bool value) {
                    mylocaleProvider.toggleTheme();
                  },
                );
              },
            ),
          ),

          const Divider(),

          // // Profile Information Update
          // ListTile(
          //   title: Text(AppLocalizations.of(context)!.profileUpdateText),
          //   trailing: const Icon(Icons.person),
          //   onTap: () {
          //     _navigateToProfileUpdateScreen(context);
          //   },
          // ),

          // // Password Update
          // ListTile(
          //   title: Text(AppLocalizations.of(context)!.passwordUpdateText),
          //   trailing: const Icon(Icons.lock),
          //   onTap: () {
          //     _navigateToPasswordUpdateScreen(context);
          //   },
          // ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguageText),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () async {
                  await localeProvider.setLanguagePreference('en');
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Français'),
                onTap: () async {
                  await localeProvider.setLanguagePreference('fr');
                  localeProvider.setLocale(const Locale('fr'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('العربية'),
                onTap: () async {
                  await localeProvider.setLanguagePreference('ar');
                  localeProvider.setLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToProfileUpdateScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileUpdateScreen(),
      ),
    );
  }

  void _navigateToPasswordUpdateScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PasswordUpdateScreen(),
      ),
    );
  }
}

class ProfileUpdateScreen extends StatelessWidget {
  const ProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.profileUpdateText)),
      body: Center(child: Text('Profile update form goes here')),
    );
  }
}

class PasswordUpdateScreen extends StatelessWidget {
  const PasswordUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.passwordUpdateText)),
      body: Center(child: Text('Password update form goes here')),
    );
  }
}
