library gluttex_impl_app;

import 'dart:developer';

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/app/Person.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class AppUserServiceImpl implements AppUserService {
  List<AppUserCategory> categories = [];
  @override
  Future<int?> addAppUser(AppUser appUser) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addAppUserEndpoint,
        appUser.toJson());
  }

  @override
  Future<AppUser?> updateAppUser(AppUser appUser) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return AppUser.fromJson(await storageService.update(
        GluttexConstants.apiBaseUrl + GluttexConstants.updateAppUserEndpoint,
        '${appUser.id_app_user}',
        {},
        appUser.toJson()));
  }

  @override
  Future<int?> deleteAppUser(String AppUserId) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.delete(
        GluttexConstants.apiBaseUrl + GluttexConstants.deleteAppUserEndpoint,
        AppUserId);
  }

  @override
  Future<int?> updateAppUserImage(AppUser updatedAppUser) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    return await storageService.update(
        GluttexConstants.apiBaseUrl +
            GluttexConstants.updateAppUserImageEndpoint,
        '${updatedAppUser.id_app_user}',
        {'image_url': updatedAppUser.app_user_image_url},
        updatedAppUser.toJson());
  }

  @override
  Future<AppUser?> getAppUser(String id) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    try {
      // log('${await storageService.get(GluttexConstants.apiBaseUrl + GluttexConstants.appUserEndpoint, id)}');
      var data = await storageService.get(
          GluttexConstants.apiBaseUrl + GluttexConstants.appUserEndpoint, id);

      var appUsers = AppUser.fromJson(data as Map<String, dynamic>);
      var user = appUsers;
      return user;
    } catch (e, stacktrace) {
      log('$e');
      log('$stacktrace');

      return AppUser.empty();
    }
  }

  @override
  Future<List<ManagementRule>?> getManagementRules(
    int orgId,
    int supplierId,
    int userId,
    int offset,
    int limit,
  ) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final route =
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAppUserStaffEndpoint}/"
          "$orgId/$supplierId/$userId/0/$offset/$limit";

      final data = await storageService.getAll(route);

      if (data is! List) return null;

      return data
          .map((json) => ManagementRule.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stacktrace) {
      log("ERROR (getManagementRules): $e");
      log(stacktrace.toString());
      return null;
    }
  }

  @override
  Future<List<AppUser>?> searchAppUsers(
    String query,
    int offset,
    int limit,
  ) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final route =
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.searchAppUserEndpoint}/$query/$offset/$limit";

      final data = await storageService.getAll(route);

      if (data is! List) return null;

      return AppUser.fromJsonList(data);
    } catch (e, stacktrace) {
      log("ERROR (searchAppUsers): $e");
      log(stacktrace.toString());
      return null;
    }
  }

  @override
  Future<List<Person>?> searchPeople(
    String query,
    int offset,
    int limit,
  ) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final route =
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.searchPeopleEndpoint}/$query/$offset/$limit";

      final data = await storageService.getAll(route);

      if (data is! List) return null;

      return data
          .map((json) => Person.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stacktrace) {
      log("ERROR (searchAppUsers): $e");
      log(stacktrace.toString());
      return null;
    }
  }

  @override
  Future<List<AppUserCategory>>? getCategories() async {
    if (categories.isNotEmpty) return categories;
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all categories
      List<dynamic> responseData = await storageService.getAll(
          GluttexConstants.apiBaseUrl +
              GluttexConstants.getAppUserCategoriesEndpoint);

      // Check if the response data is not null and is a list
      // Convert the list of AppUserCategory maps to a list of Supplier objects
      List dateien = responseData;
      List<AppUserCategory?> categories = dateien
          .map((data) => AppUserCategory.fromJson(data as Map<String, dynamic>))
          .toList();
      // developer.//log('${dateien.length}');
      return categories as List<AppUserCategory>;
    } catch (e) {
      log(e.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<ManagementRule?> addUserToSupplier(
      int appUserId, int supplierId, int orgId, int privilege,
      {bool fromQR = false}) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    Map<String, dynamic> payload = {
      "id_management_rule": 0,
      "rule_ref_org": orgId,
      "rule_ref_provider": supplierId,
      "rule_ref_user": appUserId,
      "management_rule_code": privilege,
      "management_rule_status": fromQR ? "ACCEPTED" : "PENDING",
      "management_rule_expiry": "",
    };

    try {
      var data = await storageService.insert(
          GluttexConstants.apiBaseUrl + GluttexConstants.addRuleEndpoint,
          payload);

      ManagementRule managementRule =
          ManagementRule.fromJson(data as Map<String, dynamic>);

      // Now fetch the actual user data
      // You'll need to implement getUserById in your service
      // AppUser? user = await getUserById(appUserId);
      return managementRule;
    } catch (e, stacktrace) {
      log('$e');
      log('$stacktrace');
      return null;
    }
  }

  @override
  Future<ManagementRule?> updateManagementRule(
    int ruleId,
    int appUserId,
    int supplierId,
    int orgId,
    int privilege,
  ) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    Map<String, dynamic> payload = {
      "id_management_rule": ruleId,
      "rule_ref_org": orgId,
      "rule_ref_provider": supplierId,
      "rule_ref_user": appUserId,
      "management_rule_code": privilege,
      "management_rule_status": "ACTIVE",
      "management_rule_expiry": "",
    };

    try {
      var data = await storageService.update(
          GluttexConstants.apiBaseUrl +
              GluttexConstants.putAppUserStaffEndpoint +
              "/${ruleId.toString()}",
          '',
          {},
          payload);

      ManagementRule managementRule =
          ManagementRule.fromJson(data as Map<String, dynamic>);

      // Now fetch the actual user data
      // You'll need to implement getUserById in your service
      // AppUser? user = await getUserById(appUserId);
      return managementRule;
    } catch (e, stacktrace) {
      log('$e');
      log('$stacktrace');
      return null;
    }
  }

  @override
  Future<bool> deleteManagementRule(int ruleId) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    try {
      var data = await storageService.delete(
        GluttexConstants.apiBaseUrl +
            GluttexConstants.deleteAppUserStaffEndpoint,
        ruleId.toString(),
      );
      // Now fetch the actual user data
      // You'll need to implement getUserById in your service
      // AppUser? user = await getUserById(appUserId);
      return true;
    } catch (e, stacktrace) {
      log('$e');
      log('$stacktrace');
      return false;
    }
  }
}
