import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_impl_mediation/preferenceChangeNotifier.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.selectLanguageText)),
      body: ListView(
        children: [
          ListTile(
            title: Text('English'),
            onTap: () async {
              await localeProvider.setLanguagePreference('en');
              localeProvider.setLocale(const Locale('en'));
            },
          ),
          ListTile(
            title: Text('Français'),
            onTap: () async {
              await localeProvider.setLanguagePreference('fr');
              localeProvider.setLocale(const Locale('fr'));
            },
          ),
          ListTile(
            title: Text('العربية'),
            onTap: () async {
              await localeProvider.setLanguagePreference('ar');
              localeProvider.setLocale(const Locale('ar'));
            },
          ),
        ],
      ),
    );
  }
}
