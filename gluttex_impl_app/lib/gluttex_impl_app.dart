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
  List<AppUserCategory> _categories = [];

  @override
  Future<int?> addAppUser(AppUser appUser) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.addAppUserEndpoint}';
      log('Adding app user at: $url', name: 'AppUserServiceImpl');
      log('User data: ${appUser.toJson()}', name: 'AppUserServiceImpl');

      final result = await storageService.insert(url, appUser.toJson());

      if (result == null) {
        log('Failed to add app user: null response',
            name: 'AppUserServiceImpl');
        return null;
      }

      log('Add user result: $result', name: 'AppUserServiceImpl');
      return result['id_app_user'] as int?;
    } catch (e, stacktrace) {
      log('Error adding app user: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
      return null;
    }
  }

  @override
  Future<AppUser?> updateAppUser(AppUser appUser) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.updateAppUserEndpoint}/${appUser.id_app_user}';
      log('Updating app user at: $url', name: 'AppUserServiceImpl');

      final result = await storageService.update(
        url,
        appUser.id_app_user.toString(),
        {},
        appUser.toJson(),
      );

      if (result == null) {
        log('Failed to update app user: null response',
            name: 'AppUserServiceImpl');
        return null;
      }

      return AppUser.fromJson(result as Map<String, dynamic>);
    } catch (e, stacktrace) {
      log('Error updating app user: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
      return null;
    }
  }

  @override
  Future<int?> deleteAppUser(String appUserId) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteAppUserEndpoint}/$appUserId';
      log('Deleting app user at: $url', name: 'AppUserServiceImpl');

      final result = await storageService.delete(url, appUserId);

      log('Delete result: $result', name: 'AppUserServiceImpl');
      return result;
    } catch (e, stacktrace) {
      log('Error deleting app user: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
      return null;
    }
  }

  @override
  Future<int?> updateAppUserImage(AppUser updatedAppUser) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.updateAppUserImageEndpoint}';
      log('Updating app user image at: $url', name: 'AppUserServiceImpl');

      final result = await storageService.update(
        url,
        updatedAppUser.id_app_user.toString(),
        {'image_url': updatedAppUser.app_user_image_url ?? ''},
        updatedAppUser.toJson(),
      );

      return result as int?;
    } catch (e, stacktrace) {
      log('Error updating app user image: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
      return null;
    }
  }

  @override
  Future<AppUser?> getAppUser(String id) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.appUserEndpoint}/$id';
      log('Getting app user from: $url', name: 'AppUserServiceImpl');

      final data = await storageService.get(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.appUserEndpoint}',
        id,
      );

      if (data == null) {
        log('App user not found: $id', name: 'AppUserServiceImpl');
        return AppUser.empty();
      }

      // Handle different response formats
      if (data is Map) {
        return AppUser.fromJson(data as Map<String, dynamic>);
      } else if (data is List && data.isNotEmpty) {
        return AppUser.fromJson(data[0] as Map<String, dynamic>);
      }

      log('Unexpected response format: ${data.runtimeType}',
          name: 'AppUserServiceImpl');
      return AppUser.empty();
    } catch (e, stacktrace) {
      log('Error getting app user: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
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

      // Build URL with query parameters
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getStaffEndpoint}'
          '?org_id=$orgId&provider_id=$supplierId&user_id=$userId&offset=$offset&limit=$limit';

      log('Getting management rules from: $url', name: 'AppUserServiceImpl');

      final data = await storageService.getAll(url);

      if (data == null) {
        log('No management rules found', name: 'AppUserServiceImpl');
        return null;
      }

      List<ManagementRule> rules = [];

      if (data is List) {
        rules = data
            .map(
                (json) => ManagementRule.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('data')) {
        final dataList = data['data'];
        if (dataList is List) {
          rules = dataList
              .map((json) =>
                  ManagementRule.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      log('Found ${rules.length} management rules', name: 'AppUserServiceImpl');
      return rules;
    } catch (e, stacktrace) {
      log('Error getting management rules: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
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

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.searchAppUserEndpoint}'
          '?query=$query&offset=$offset&limit=$limit';

      log('Searching app users with query: $query', name: 'AppUserServiceImpl');

      final data = await storageService.getAll(url);

      if (data == null) {
        log('No app users found', name: 'AppUserServiceImpl');
        return null;
      }

      if (data is List) {
        return AppUser.fromJsonList(data);
      } else if (data is Map && data.containsKey('data')) {
        final dataList = data['data'];
        if (dataList is List) {
          return AppUser.fromJsonList(dataList);
        }
      }

      log('Unexpected response format: ${data.runtimeType}',
          name: 'AppUserServiceImpl');
      return null;
    } catch (e, stacktrace) {
      log('Error searching app users: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
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

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.searchPersonsByNameEndpoint}'
          '?query=$query&offset=$offset&limit=$limit';

      log('Searching people with query: $query', name: 'AppUserServiceImpl');

      final data = await storageService.getAll(url);

      if (data == null) {
        log('No people found', name: 'AppUserServiceImpl');
        return null;
      }

      List<Person> people = [];

      if (data is List) {
        people = data
            .map((json) => Person.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('data')) {
        final dataList = data['data'];
        if (dataList is List) {
          people = dataList
              .map((json) => Person.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      log('Found ${people.length} people', name: 'AppUserServiceImpl');
      return people;
    } catch (e, stacktrace) {
      log('Error searching people: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
      return null;
    }
  }

  @override
  Future<Person?> getPerson(String id) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.personEndpoint}/$id';
      log('Getting person from: $url', name: 'AppUserServiceImpl');

      final data = await storageService.get(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.personEndpoint}',
        id,
      );

      if (data == null) {
        log('Person not found: $id', name: 'AppUserServiceImpl');
        return Person.empty();
      }

      // Handle different response formats
      if (data is Map) {
        return Person.fromJson(data as Map<String, dynamic>);
      } else if (data is List && data.isNotEmpty) {
        return Person.fromJson(data[0] as Map<String, dynamic>);
      }

      log('Unexpected response format: ${data.runtimeType}',
          name: 'AppUserServiceImpl');
      return Person.empty();
    } catch (e, stacktrace) {
      log('Error getting person: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
      return Person.empty();
    }
  }

  @override
  Future<List<AppUserCategory>>? getCategories() async {
    if (_categories.isNotEmpty) {
      log('Returning cached categories: ${_categories.length}',
          name: 'AppUserServiceImpl');
      return _categories;
    }

    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getAppUserCategoriesEndpoint}';
      log('Getting app user categories from: $url', name: 'AppUserServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        log('No categories found', name: 'AppUserServiceImpl');
        return [];
      }

      List<AppUserCategory> categories = [];

      if (responseData is List) {
        categories = responseData
            .map((data) =>
                AppUserCategory.fromJson(data as Map<String, dynamic>))
            .toList();
      } else if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          categories = dataList
              .map((data) =>
                  AppUserCategory.fromJson(data as Map<String, dynamic>))
              .toList();
        }
      }

      _categories = categories;
      log('Found ${_categories.length} categories', name: 'AppUserServiceImpl');

      return _categories;
    } catch (e) {
      log('Error getting categories: $e', name: 'AppUserServiceImpl');
      return [];
    }
  }

  @override
  Future<ManagementRule?> addUserToSupplier(
      int appUserId, int supplierId, int orgId, int privilege,
      {bool fromQR = false}) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.addRuleEndpoint}';
      log('Adding user to supplier at: $url', name: 'AppUserServiceImpl');

      final payload = {
        "id_management_rule": 0,
        "rule_ref_org": orgId,
        "rule_ref_provider": supplierId,
        "rule_ref_user": appUserId,
        "management_rule_code": privilege,
        "management_rule_status": fromQR ? "ACTIVE" : "PENDING",
        "management_rule_expiry": null,
      };

      log('Payload: $payload', name: 'AppUserServiceImpl');

      final data = await storageService.insert(url, payload);

      if (data == null) {
        log('Failed to add user to supplier: null response',
            name: 'AppUserServiceImpl');
        return null;
      }

      return ManagementRule.fromJson(data as Map<String, dynamic>);
    } catch (e, stacktrace) {
      log('Error adding user to supplier: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
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
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.updateStaffEndpoint}/$ruleId';
      log('Updating management rule at: $url', name: 'AppUserServiceImpl');

      final payload = {
        "id_management_rule": ruleId,
        "rule_ref_org": orgId,
        "rule_ref_provider": supplierId,
        "rule_ref_user": appUserId,
        "management_rule_code": privilege,
        "management_rule_status": "ACTIVE",
        "management_rule_expiry": null,
      };

      log('Payload: $payload', name: 'AppUserServiceImpl');

      final data = await storageService.update(
        url,
        ruleId.toString(),
        {},
        payload,
      );

      if (data == null) {
        log('Failed to update management rule: null response',
            name: 'AppUserServiceImpl');
        return null;
      }

      return ManagementRule.fromJson(data as Map<String, dynamic>);
    } catch (e, stacktrace) {
      log('Error updating management rule: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
      return null;
    }
  }

  @override
  Future<bool> deleteManagementRule(int ruleId) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteStaffEndpoint}/$ruleId';
      log('Deleting management rule at: $url', name: 'AppUserServiceImpl');

      final result = await storageService.delete(url, ruleId.toString());

      log('Delete result: $result', name: 'AppUserServiceImpl');
      return result != null && result >= 200 && result < 300;
    } catch (e, stacktrace) {
      log('Error deleting management rule: $e', name: 'AppUserServiceImpl');
      log('Stacktrace: $stacktrace', name: 'AppUserServiceImpl');
      return false;
    }
  }

  // Helper method to clear cache
  void clearCache() {
    _categories.clear();
    log('App user service cache cleared', name: 'AppUserServiceImpl');
  }

  // Helper method to refresh categories
  Future<List<AppUserCategory>> refreshCategories() async {
    _categories.clear();
    final categories = await getCategories();
    return categories ?? [];
  }
}
