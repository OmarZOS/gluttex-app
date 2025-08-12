import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
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
      floatingActionButton: _buildFloatingActionButtons(context, theme),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Consumer<AppUserNotifier>(
              builder: (context, appUserNotifier, _) {
                final user = appUserNotifier.appUser;
                return user is AppUser
                    ? _buildProfileContent(context, user, theme)
                    : const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'floating-button-4',
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          onPressed: () => showIllnessInfoPopup(context),
          // _navigateToSettings(context)
          child: const Icon(Icons.info),
        ),
      ],
    );
  }

  Widget _buildProfileContent(
      BuildContext context, AppUser user, ThemeData theme) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserAvatarSection(user, theme),
          // const SizedBox(height: 8),

          _buildProfileSection(
            title: localizations.userInfoText,
            children: [
              _buildInfoTile(localizations.usernameText, user.app_user_name),
              // _buildInfoTile(localizations.emailText, user.app_user_email),
              _buildInfoTile(
                  localizations.userTypeText, user.app_user_type_desc),
            ],
            theme: theme,
          ),
          _buildProfileSection(
            title: localizations.personalInfoText,
            children: [
              _buildInfoTile(localizations.firstNameText, user.personFirstName),
              _buildInfoTile(localizations.lastNameText, user.personLastName),
              _buildInfoTile(localizations.birthdayText, user.personBirthDate),
              _buildInfoTile(localizations.genderText, user.personGender),
            ],
            theme: theme,
          ),
          _buildProfileSection(
            title: localizations.locationInfoText,
            children: [
              _buildInfoTile(localizations.cityText, user.addressCity),
              _buildInfoTile(localizations.countryText, user.addressCountry),
            ],
            theme: theme,
          ),
        ],
      ),
    );
  }

  void showIllnessInfoPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: _buildIllnessInfoTab(context),
          ),
        );
      },
    );
  }

  Widget _buildIllnessInfoTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              AppLocalizations.of(context)!.illnessOverviewTitle),
          _buildSectionText(
              AppLocalizations.of(context)!.illnessOverviewContent),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.symptomsTitle),
          _buildSymptomItem(AppLocalizations.of(context)!.symptom1),
          _buildSymptomItem(AppLocalizations.of(context)!.symptom2),
          _buildSymptomItem(AppLocalizations.of(context)!.symptom3),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.treatmentTitle),
          _buildSectionText(AppLocalizations.of(context)!.treatmentContent),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.resourcesTitle),
          _buildResourceLink(AppLocalizations.of(context)!.resource1),
          _buildResourceLink(AppLocalizations.of(context)!.resource2),
        ],
      ),
    );
  }

  Widget _buildSymptomItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // Handle link opening
        },
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildUserAvatarSection(AppUser user, ThemeData theme) {
    return GestureDetector(
      // onTap: _isEditing ? _changeProfilePicture : null,
      child: Center(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.25,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    child: user.app_user_image_url != null
                        ? ClipOval(
                            child: Image.network(
                              GluttexConstants.fsBaseUrl +
                                  user.app_user_image_url!,
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: MediaQuery.of(context).size.width * 0.5,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.5,
                                  // color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(Icons.person,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.4),
                                  ),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${user.personFirstName} ${user.personLastName}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
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
              (value?.isNotEmpty ?? false) ? value! : '--',
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
