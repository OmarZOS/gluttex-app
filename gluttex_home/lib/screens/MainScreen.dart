import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
