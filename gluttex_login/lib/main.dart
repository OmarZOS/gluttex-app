import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AuthService.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:gluttex_impl_app/gluttex_impl_auth.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_login/screens/login_screen.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_impl_app/gluttex_impl_app.dart';
import 'package:gluttex_impl_mediation/gluttex_impl_mediation.dart';

void main() {
  GluttexLocator.registerSingletonService<AppUserService>(AppUserServiceImpl());
  GluttexLocator.registerSingletonService<StorageService>(StorageServiceImpl());
  GluttexLocator.registerSingletonService<AuthService>(AuthServiceImpl());

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppUserNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppUserNotifier(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
