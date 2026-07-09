import 'package:app_constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_constants.dart';
import 'package:tabbed_home/screens/PasswordChangeScreen.dart';
import 'package:tabbed_home/screens/PdfViewerScreen.dart';
import 'package:tabbed_home/screens/app_user_update_form_screen.dart';
import 'package:event/user_change_notifier.dart';
import 'package:event/preferenceChangeNotifier.dart';
import 'package:health/screens/informations_screen.dart';
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
                    Consumer<LocaleProvider>(
                      builder: (context, localeProvider, child) =>
                          _LanguageTile(localeProvider: localeProvider),
                    ),
                    const SizedBox(height: 8),
                    _ThemeModeTile(),
                  ],
                ),
                const SizedBox(height: 24),
                Consumer<AppUserNotifier>(
                  builder: (context, authProvider, child) {
                    return _SettingsSection(
                      title: AppLocalizations.of(context)!.accountText,
                      children: [
                        if (authProvider.isAuthenticated)
                          Column(
                            children: [
                              _ProfileUpdateTile(),
                              const SizedBox(height: 8),
                              _PasswordUpdateTile(),
                              const SizedBox(height: 8),
                            ],
                          ),
                        _LegalDocumentsTile(),
                        const SizedBox(height: 8),
                        _AboutTile(),
                        const SizedBox(height: 8),
                        _LogOutTile(
                          () => _handleLogout(context, authProvider),
                        ),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, AppUserNotifier authProvider) {
    if (authProvider.isAuthenticated) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.loggingOutText),
            content: Text(AppLocalizations.of(context)!.logoutConsentText),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancelTxt),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  _performLogout(context, authProvider);
                },
                child: Text(AppLocalizations.of(context)!.logoutText),
              ),
            ],
          );
        },
      );
    } else {
      // User is not logged in - navigate to login
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _performLogout(BuildContext context, AppUserNotifier authProvider) {
    // Close settings screen first
    Navigator.pop(context);

    // Sign out from auth provider
    authProvider.signOut();

    // Navigate to login screen and remove all routes
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );

    // Optional: Show logout success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.logoutText),
        duration: const Duration(seconds: 2),
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
        onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.userEdit,
              arguments: {"user": notifier.appUser},
            ));
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
  final VoidCallback onLogout;

  const _LogOutTile(this.onLogout);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppUserNotifier>(
      builder: (context, authProvider, child) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              authProvider.isAuthenticated ? Icons.logout : Icons.login,
            ),
          ),
          title: Text(
            authProvider.isAuthenticated
                ? AppLocalizations.of(context)!.logoutText
                : AppLocalizations.of(context)!.loginText,
          ),
          onTap: onLogout,
        );
      },
    );
  }
}

class _LegalDocumentsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.description),
      ),
      trailing: const Icon(Icons.chevron_right),
      title: Text(AppLocalizations.of(context)!.legalDocumentsTitle),
      onTap: () => _showLegalDocumentsDialog(context),
    );
  }

  void _showLegalDocumentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.legalDocumentsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDocumentOption(
              context,
              icon: Icons.privacy_tip,
              title: AppLocalizations.of(context)!.privacyPolicy,
              onTap: () => _openPdfViewer(
                context,
                screenTitle: AppLocalizations.of(context)!.privacyPolicy,
                title: AppLocalizations.of(context)!.privacyPolicy,
                docType: "policy",
              ),
            ),
            const SizedBox(height: 12),
            _buildDocumentOption(
              context,
              icon: Icons.assignment,
              title: AppLocalizations.of(context)!.termsOfUse,
              onTap: () => _openPdfViewer(context,
                  title: AppLocalizations.of(context)!.termsOfUse,
                  docType: 'terms',
                  screenTitle: AppLocalizations.of(context)!.termsOfUse
                  // assetPath: 'assets/documents/terms_of_use.pdf',
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _openPdfViewer(BuildContext context,
      {required String title,
      required String docType,
      required String screenTitle}) {
    final locale = Localizations.localeOf(context).languageCode; //

    final pdfPath = 'assets/docs/${docType}_${locale}.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          assetPath: pdfPath, // Must match pubspec.yaml
          screenTitle: screenTitle,
        ),
      ),
    );
  }
}

void _showLegalDocumentsDialog(BuildContext context) {
  _showLegalDocumentsDialog(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileUpdateText),
      ),
      body: Center(child: Text(AppLocalizations.of(context)!.comingSoon)),
    );
  }
}

class _AboutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.question_mark),
      ),
      title: Text(AppLocalizations.of(context)!.aboutProvider),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HealthInfoScreen(),
        ),
      ),
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
