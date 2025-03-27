import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_home/screens/SettingsScreen.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () => _navigateToSettings(context),
        child: const Icon(Icons.settings),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppLocalizations.of(context)!.profileText),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.grey[850]!, Colors.grey[900]!]
                        : [
                            theme.colorScheme.primary.withOpacity(0.1),
                            Colors.white
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<AppUserNotifier>(
              builder: (context, appUserNotifier, _) {
                final user = appUserNotifier.appUser;
                return user is AppUser
                    ? _buildProfileContent(context, user)
                    : const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
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

  Widget _buildProfileContent(BuildContext context, AppUser user) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserAvatarSection(user),
          const SizedBox(height: 24),
          _buildProfileSection(
            title: localizations.userInfoText,
            children: [
              _buildInfoTile(localizations.usernameText, user.app_user_name),
              _buildInfoTile(
                  localizations.userTypeText, user.app_user_type_desc),
              _buildInfoTile(localizations.bloodTypeText, user.bloodTypeDesc),
            ],
          ),
          _buildProfileSection(
            title: localizations.personalInfoText,
            children: [
              _buildInfoTile(localizations.firstNameText, user.personFirstName),
              _buildInfoTile(localizations.lastNameText, user.personLastName),
              _buildInfoTile(localizations.birthdayText, user.personBirthDate),
              _buildInfoTile(localizations.genderText, user.personGender),
              _buildInfoTile(
                  localizations.nationalityText, user.personNationality),
            ],
          ),
          _buildProfileSection(
            title: localizations.locationInfoText,
            children: [
              _buildInfoTile(localizations.locationNameText, user.locationName),
              _buildInfoTile(localizations.streetText, user.addressStreet),
              _buildInfoTile(localizations.cityText, user.addressCity),
              _buildInfoTile(
                  localizations.postalCodeText, user.addressPostalCode),
              _buildInfoTile(localizations.countryText, user.addressCountry),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatarSection(AppUser user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child: user.app_user_image != null
                ? ClipOval(child: Image.memory(user.app_user_image!))
                : const Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 8),
          Text(
            '${user.personFirstName} ${user.personLastName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              (value!.isNotEmpty) ? value : '--',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
