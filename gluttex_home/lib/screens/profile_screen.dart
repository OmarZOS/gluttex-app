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
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  // late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppUserNotifier>(context, listen: false).appUser;
    _firstNameController =
        TextEditingController(text: user?.personFirstName ?? '');
    _lastNameController =
        TextEditingController(text: user?.personLastName ?? '');
    // _emailController = TextEditingController(text: user. ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    // _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: _buildFloatingActionButtons(context, theme),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                AppLocalizations.of(context)!.profileText,
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  shadows: isDarkMode
                      ? [const Shadow(color: Colors.black, blurRadius: 4)]
                      : null,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                            const Color.fromARGB(255, 100, 110, 105),
                            const Color(0xFF186A3B)
                          ] // Darker green shades
                        : [
                            const Color(0xFF2ECC71),
                            const Color.fromARGB(255, 143, 197, 166)
                          ], // Your main color + slightly darker
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
        if (_isEditing)
          FloatingActionButton(
            heroTag: 'save',
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            onPressed: _saveChanges,
            child: const Icon(Icons.save),
          ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'settings',
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          onPressed: () => _navigateToSettings(context),
          child: Icon(_isEditing ? Icons.close : Icons.settings),
        ),
      ],
    );
  }

  void _navigateToSettings(BuildContext context) {
    if (_isEditing) {
      setState(() => _isEditing = false);
    } else {
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
          const SizedBox(height: 24),
          if (!_isEditing) ...[
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
                _buildInfoTile(
                    localizations.firstNameText, user.personFirstName),
                _buildInfoTile(localizations.lastNameText, user.personLastName),
                _buildInfoTile(
                    localizations.birthdayText, user.personBirthDate),
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
          ] else ...[
            _buildEditableProfileSection(localizations, theme)
          ],
        ],
      ),
    );
  }

  Widget _buildUserAvatarSection(AppUser user, ThemeData theme) {
    return GestureDetector(
      onTap: _isEditing ? _changeProfilePicture : null,
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
                    radius: 50,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    child: user.app_user_image != null
                        ? ClipOval(
                            child: Image.memory(
                              user.app_user_image!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: theme.colorScheme.onPrimary,
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
            if (_isEditing)
              TextButton(
                onPressed: _changeProfilePicture,
                child: Text(
                  AppLocalizations.of(context)!.changePhotoText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
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

  Widget _buildEditableProfileSection(AppLocalizations loc, ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildProfileSection(
            title: loc.personalInfoText,
            children: [
              _buildEditableField(
                label: loc.firstNameText,
                controller: _firstNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.fieldRequired;
                  }
                  return null;
                },
                theme: theme,
              ),
              _buildEditableField(
                label: loc.lastNameText,
                controller: _lastNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.fieldRequired;
                  }
                  return null;
                },
                theme: theme,
              ),
            ],
            theme: theme,
          ),
          // _buildProfileSection(
          //   title: loc.contactInfoText,
          //   children: [
          //     _buildEditableField(
          //       label: loc.emailText,
          //       controller: _emailController,
          //       validator: (value) {
          //         if (value == null || value.isEmpty) {
          //           return loc.fieldRequired;
          //         }
          //         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          //             .hasMatch(value)) {
          //           return loc.invalidEmail;
          //         }
          //         return null;
          //       },
          //       theme: theme,
          //     ),
          //   ],
          //   theme: theme,
          // ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        validator: validator,
      ),
    );
  }

  Future<void> _changeProfilePicture() async {
    // Implement image picker logic
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Save changes to backend
      // final notifier = Provider.of<AppUserNotifier>(context, listen: false);
      try {
        // await notifier.updateUserProfile(
        //   firstName: _firstNameController.text,
        //   lastName: _lastNameController.text,
        //   email: _emailController.text,
        // );
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileUpdateSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
