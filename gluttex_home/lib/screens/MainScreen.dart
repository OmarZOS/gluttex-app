import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_home/gluttex_router.dart';
import 'package:gluttex_home/main.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_localiser/screens/map_picker_screen.dart';
import 'package:gluttex_login/screens/login_screen.dart';
import 'package:gluttex_login/screens/registration_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppUserNotifier>(
      builder: (context, appUserNotifier, child) {
        final appUser = appUserNotifier.appUser;

        if (appUser == null) {
          globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        } else {
          globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        }

        // Return an empty container or a loading screen if needed
        return Container();
      },
    );
  }
}
