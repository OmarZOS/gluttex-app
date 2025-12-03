// UserService.dart
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/app/ManagementRule.dart';

import '../AppUser.dart';

// AppUserService.dart
abstract class AppUserService {
  Future<List<AppUserCategory>?>? getCategories() async {
    return null;
  }

  Future<AppUser?> getAppUser(String idAppUser) async {
    return null;
  }

  Future<List<ManagementRule>?>? getManagementRules(
    int orgId,
    int supplierId,
    int userId,
    int offset,
    int limit,
  ) async {
    return null;
  }

  Future<List<AppUser>?> searchAppUsers(
    String query,
    int offset,
    int limit,
  ) async {
    return null;
  }

  Future<AppUser?> updateAppUser(AppUser appUser) async {
    return null;
  }

  Future<int?> addAppUser(AppUser appUser) async {
    return null;
  }

  Future<int?> updateAppUserImage(AppUser updatedAppUser) async {
    return null;
  }

  Future<int?> deleteAppUser(String appUserId) async {
    return null;
  }

  Future<ManagementRule?> addUserToSupplier(
      int appUserId, int supplierId, int orgId, int privilege,
      {bool fromQR = false}) async {
    return null;
  }

  Future<ManagementRule?> updateManagementRule(
    int ruleId,
    int appUserId,
    int supplierId,
    int orgId,
    int privilege,
  ) async {
    return null;
  }

  Future<bool> deleteManagementRule(int ruleId) async {
    return false;
  }
}
