import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_home/screens/PasswordChangeScreen.dart';
import 'package:gluttex_home/screens/app_user_update_form_screen.dart';
import 'package:gluttex_home/screens/home_screen.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_impl_mediation/preferenceChangeNotifier.dart';
import 'package:gluttex_login/screens/login_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SettingsSection(
                  title: AppLocalizations.of(context)!.appearanceText,
                  children: [
                    _LanguageTile(
                        localeProvider: Provider.of<LocaleProvider>(context,
                            listen: false)),
                    const SizedBox(height: 8),
                    _ThemeModeTile(),
                  ],
                ),
                const SizedBox(height: 24),
                _SettingsSection(
                  title: AppLocalizations.of(context)!.accountText,
                  children: [
                    _ProfileUpdateTile(),
                    const SizedBox(height: 8),
                    _PasswordUpdateTile(),
                    const SizedBox(height: 8),
                    _LogOutTile()
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LocaleProvider localeProvider;

  const _LanguageTile({required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.language),
      ),
      title: Text(AppLocalizations.of(context)!.languageText),
      // subtitle: Text(
      //   AppLocalizations.of(context)!
      //       .currentLanguage(localeProvider.languagePreference ?? ""),
      //   style: Theme.of(context).textTheme.bodySmall,
      // ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguageText),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOption(
                language: 'English',
                locale: const Locale('en'),
                localeProvider: localeProvider,
              ),
              const Divider(height: 1),
              _LanguageOption(
                language: 'Français',
                locale: const Locale('fr'),
                localeProvider: localeProvider,
              ),
              const Divider(height: 1),
              _LanguageOption(
                language: 'العربية',
                locale: const Locale('ar'),
                localeProvider: localeProvider,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String language;
  final Locale locale;
  final LocaleProvider localeProvider;

  const _LanguageOption({
    required this.language,
    required this.locale,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(language),
      trailing: localeProvider.languagePreference == locale.languageCode
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () async {
        await localeProvider.setLanguagePreference(locale.languageCode);
        localeProvider.setLocale(locale);
        Navigator.pop(context);
      },
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isDarkMode = localeProvider.isDarkMode ??
            MediaQuery.of(context).platformBrightness == Brightness.dark;

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          title: Text(AppLocalizations.of(context)!.darkModeText),
          trailing: Switch.adaptive(
            value: isDarkMode,
            onChanged: (value) => localeProvider.toggleTheme(),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

class _ProfileUpdateTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppUserNotifier notifier =
        Provider.of<AppUserNotifier>(context, listen: false);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person),
      ),
      title: Text(AppLocalizations.of(context)!.profileUpdateText),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AppUserEditFormScreen(appUser: notifier.appUser),
        ),
      ),
    );
  }
}

class _PasswordUpdateTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock),
      ),
      title: Text(AppLocalizations.of(context)!.passwordUpdateText),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PasswordChangeScreen(),
        ),
      ),
    );
  }
}

class _LogOutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout),
        ),
        title: Text(AppLocalizations.of(context)!.logoutText),
        // trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            {Provider.of<AppUserNotifier>(context, listen: false).logout()});
  }
}

class ProfileUpdateScreen extends StatelessWidget {
  const ProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileUpdateText),
      ),
      body: Center(child: Text(AppLocalizations.of(context)!.comingSoon)),
    );
  }
}

class PasswordUpdateScreen extends StatelessWidget {
  const PasswordUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.passwordUpdateText),
      ),
      body: Center(child: Text(AppLocalizations.of(context)!.comingSoon)),
    );
  }
}
