import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_home/screens/home_screen.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_login/screens/login_screen.dart';
import 'package:gluttex_login/screens/registration_screen.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final appUser =
            Provider.of<AppUserNotifier>(context, listen: false).appUser;

        switch (settings.name) {
          case AppRoutes.home:
            return _buildGuardedRoute(appUser, HomePage(), LoginScreen());
          case AppRoutes.login:
            return LoginScreen();
          case AppRoutes.registration:
            return RegistrationForm();
          default:
            return LoginScreen();
        }
      },
      settings: settings,
    );
  }

  static Widget _buildGuardedRoute(
      AppUser? appUser, Widget authorizedScreen, Widget unauthorizedScreen) {
    if (appUser != null) {
      return authorizedScreen;
    } else {
      return unauthorizedScreen;
    }
  }
}
