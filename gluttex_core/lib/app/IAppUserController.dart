import 'package:gluttex_core/app/AppUser.dart';

abstract class IAppUserController {
  AppUser? get appUser;
  bool get isLoggedIn;
  bool get isCookingChef;
  int get selectedTabIndex;

  Future<void> fetchAppUser(String userId);
  void setSelectedTabIndex(int index);
  void logout();

  Future<void> signInAsGuest();
  Future<int?> addAppUser(AppUser appUser);
  Future<int?> updateAppUserImage(AppUser appUser);
  Future<int?> deleteAppUser(String idAppuser);

  Future<dynamic> signUpWithData(Map<String, dynamic> data);
  Future<void> signInWithUsernameAndPassword(String username, String password);

  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithFacebook();
  Future<void> signOut();
}
