import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_home/screens/LanguageSelectionScreen.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return const LanguageSelectionScreen();
            }),
          );
        },
        child: const Icon(Icons.abc), // Replace with the desired icon
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileText),
        // actions: [IconButton(icon: Icon(Icons.edit), onPressed: () {})]
      ),
      body: Consumer<AppUserNotifier>(
        builder: (context, appUserNotifier, child) {
          // await appUserNotifier.fetchAppUser("1");
          var user = appUserNotifier.appUser;

          return (user is AppUser)
              ? _buildProfile(user)
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          Text(
            value == "" ? "--" : value,
            style: const TextStyle(
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(AppUser? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Center(
          //     child: CircleAvatar(
          //   radius: MediaQuery.of(context).size.width / 2.5,
          //   backgroundImage: user!.app_user_image,
          //   backgroundColor: Colors.transparent,
          // )),
          const SizedBox(height: 20),

          // User Info
          _buildSectionTitle(AppLocalizations.of(context)!.userInfoText),
          _buildInfoRow(
              AppLocalizations.of(context)!.usernameText, user!.app_user_name!),
          // _buildInfoRow('Preferences', user.app_user_preferences!),
          _buildInfoRow(AppLocalizations.of(context)!.userTypeText,
              user.app_user_type_desc!),
          _buildInfoRow(
              AppLocalizations.of(context)!.bloodTypeText, user.bloodTypeDesc),

          // Person Info
          _buildSectionTitle(AppLocalizations.of(context)!.personalInfoText),
          _buildInfoRow(AppLocalizations.of(context)!.firstNameText,
              user.personFirstName),
          _buildInfoRow(
              AppLocalizations.of(context)!.lastNameText, user.personLastName),
          _buildInfoRow(
              AppLocalizations.of(context)!.birthdayText, user.personBirthDate),
          _buildInfoRow(
              AppLocalizations.of(context)!.genderText, user.personGender),
          _buildInfoRow(AppLocalizations.of(context)!.nationalityText,
              user.personNationality),

          // Location Info
          _buildSectionTitle(AppLocalizations.of(context)!.locationInfoText),
          _buildInfoRow(AppLocalizations.of(context)!.locationNameText,
              user.locationName),
          _buildInfoRow(
              AppLocalizations.of(context)!.streetText, user.addressStreet),
          _buildInfoRow(
              AppLocalizations.of(context)!.cityText, user.addressCity),
          _buildInfoRow(AppLocalizations.of(context)!.postalCodeText,
              user.addressPostalCode),
          _buildInfoRow(
              AppLocalizations.of(context)!.countryText, user.addressCountry),
          // Center(
          //   child: TextButton(
          //       onPressed: () async {
          //         final updatedUser = await Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => AppUserEditFormScreen(
          //                       initial_id_app_user: user!.id_app_user,
          //                       initial_app_user_person_id:
          //                           user!.app_user_person_id,
          //                       initial_app_user_type_id:
          //                           user!.app_user_type_id,
          //                       initial_id_app_user_type:
          //                           user!.id_app_user_type,
          //                       initial_idPerson: user!.idPerson,
          //                       initial_personDetailsId: user!.personDetailsId,
          //                       initial_idBloodType: user!.idBloodType,
          //                       initial_idLocation: user!.idLocation,
          //                       initial_locationAddressId:
          //                           user!.locationAddressId,
          //                       initial_app_user_name: user!.app_user_name,
          //                       initial_app_user_password:
          //                           user!.app_user_password,
          //                       initial_app_user_preferences:
          //                           user!.app_user_preferences,
          //                       initial_app_user_type_desc:
          //                           user!.app_user_type_desc,
          //                       initial_app_user_image: user!.app_user_image,
          //                       initial_personFirstName: user!.personFirstName,
          //                       initial_personLastName: user!.personLastName,
          //                       initial_personBirthDate: user!.personBirthDate,
          //                       initial_personGender: user!.personGender,
          //                       initial_personNationality:
          //                           user!.personNationality,
          //                       initial_locationLatitude:
          //                           user!.locationLatitude,
          //                       initial_locationLongitude:
          //                           user!.locationLongitude,
          //                       initial_locationName: user!.locationName,
          //                       initial_addressStreet: user!.addressStreet,
          //                       initial_addressCity: user!.addressCity,
          //                       initial_addressPostalCode:
          //                           user!.addressPostalCode,
          //                       initial_addressCountry: user!.addressCountry,
          //                       initial_bloodTypeDesc: user!.bloodTypeDesc,
          //                     )));
          //         if (updatedUser != null) {
          //           setState(() {
          //             user = updatedUser;
          //           });
          //         }
          //       },
          //       child: Icon(Icons.edit)),
          // )
        ],
      ),
    );
  }
}
