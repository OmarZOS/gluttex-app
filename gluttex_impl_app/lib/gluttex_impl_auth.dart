library gluttex_impl_app;

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Services/AuthService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthServiceImpl implements AuthService {
  StorageService storageService = GluttexLocator.get<StorageService>();

  @override
  Future<AppUser?> signInWithFacebook() async {
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<dynamic> signUpWithData(Map<String, dynamic> data) async {
    String destination =
        GluttexConstants.apiBaseUrl + GluttexConstants.signUpEndpoint;

    dynamic appUserData;
    appUserData =
        await storageService.signUpUsingUsernameAndPassword(destination, data);
    return appUserData;
  }

  @override
  Future<dynamic> signInWithUsernameAndPassword(
      String username, String password) async {
    String destination =
        GluttexConstants.apiBaseUrl + GluttexConstants.loginEndpoint;
    Map<String, dynamic> data = {
      "id_app_user": 0,
      "app_user_name": username,
      "app_user_password": password,
    };

    dynamic appUser =
        await storageService.signInUsingUsernameAndPassword(destination, data);

    return appUser;
  }
}
