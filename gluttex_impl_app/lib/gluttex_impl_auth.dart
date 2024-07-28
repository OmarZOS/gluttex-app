library gluttex_impl_app;

import 'dart:developer';
import 'dart:typed_data';

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/AuthService.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:insta_login/insta_login.dart';

class AuthServiceImpl implements AuthService {
  StorageService storageService = GluttexLocator.get<StorageService>();

  @override
  Future<AppUser?> signInWithFacebook() async {
    // try {
    //   final LoginResult result = await FacebookAuth.instance.login();

    //   if (result.status == LoginStatus.success) {
    //     final AccessToken accessToken = result.accessToken!;
    //     final userData = await FacebookAuth.instance.getUserData();

    //     // Retrieve user information
    //     String displayName = userData['name'] ?? "No name";
    //     String email = userData['email'] ?? "No email";
    //     String id = userData['id'] ?? "No ID";
    //     String photoUrl = userData['picture']['data']['url'] ?? "No photo";

    //     // Handle successful login
    //     log("Facebook user info:");
    //     log("Display Name: $displayName");
    //     log("Email: $email");
    //     log("ID: $id");
    //     log("Photo URL: $photoUrl");

    //     // You can now store this information in your app or database as needed
    //   } else {
    //     print("Facebook login failed: ${result.message}");
    //   }
    // } catch (error) {
    //   throw Exception("Facebook login failed: $error");
    // }
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        // Retrieve user information
        String displayName = account.displayName ?? "No name";
        String email = account.email;
        String id = account.id;
        String photoUrl = account.photoUrl ?? "No photo";

        // Handle successful login
        log("Google user info:");
        log("Display Name: $displayName");
        log("Email: $email");
        log("ID: $id");
        log("Photo URL: $photoUrl");
      }
    } catch (error) {
      throw Exception("Google login failed: $error");
    }
  }

  // Future<AppUser?> signInWithInstagram() async {
  //   throw UnimplementedError();
  // }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<dynamic> signUpWithData(Map<String, dynamic> data) async {
    String destination =
        GluttexConstants.apiBaseUrl + GluttexConstants.addAppUserEndpoint;
    // Map<String, dynamic> data = {
    //   "id_app_user": 0,
    //   "app_user_name": username,
    //   "app_user_password": password,
    // };

    dynamic appUserData;
    appUserData =
        await storageService.signUpUsingUsernameAndPassword(destination, data);
    return appUserData;
  }

  @override
  Future<dynamic> signInWithUsernameAndPassword(
      String username, String password) async {
    // TODO: implement signInWithUsernameAndPassword
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
