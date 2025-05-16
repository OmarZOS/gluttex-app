import 'package:flutter/material.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_login/screens/login_screen.dart';
import 'package:provider/provider.dart';

class GuardedRoute extends StatelessWidget {
  final Widget child;

  const GuardedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final appUser = context.watch<AppUserNotifier>().appUser;

    if (appUser != null) {
      return child;
    } else {
      return const LoginScreen();
    }
  }
}
