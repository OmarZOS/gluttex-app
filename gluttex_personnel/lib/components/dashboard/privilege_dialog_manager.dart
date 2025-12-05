import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_personnel/components/privilege_dialog/privilege_dialog.dart';

class PrivilegeDialogManager {
  static Future<void> showPrivilegeDialog({
    required BuildContext context,
    required AppUser user,
    required bool isPending,
    required int ruleId,
    required int supplierId,
    required String supplierName,
    required PersonnelNotifier personnelNotifier,
    required int orgId,
    required VoidCallback onRefresh,
  }) async {
    int? existingPrivileges;

    if (!isPending) {
      final rules = await personnelNotifier.getUserPrivileges(
        ruleId: ruleId,
        userId: user.id_app_user ?? 0,
        supplierId: supplierId,
      );

      if (rules != null && rules.isNotEmpty) {
        final ruleForSupplier = rules.firstWhere(
          (rule) => rule.productProvider?.id_product_provider == supplierId,
          orElse: () => rules.first,
        );
        existingPrivileges = ruleForSupplier.management_rule_code;
      }
    }

    if (!context.mounted) return;

    final privilegesBitmask = await showDialog<int>(
      context: context,
      builder: (context) => PrivilegeDialog(
        user: user,
        supplierName: supplierName,
        initialPrivileges: existingPrivileges,
      ),
    );

    if (privilegesBitmask != null && context.mounted && !isPending) {
      await _modifyUserPrivileges(
        context: context,
        user: user,
        privileges: privilegesBitmask,
        ruleId: ruleId,
        personnelNotifier: personnelNotifier,
        supplierId: supplierId,
        orgId: orgId,
        onRefresh: onRefresh,
      );
    }
  }

  static Future<void> _modifyUserPrivileges({
    required BuildContext context,
    required AppUser user,
    required int privileges,
    required int ruleId,
    required PersonnelNotifier personnelNotifier,
    required int supplierId,
    required int orgId,
    required VoidCallback onRefresh,
  }) async {
    try {
      final rules = await personnelNotifier.getUserPrivileges(
        ruleId: ruleId,
        userId: user.id_app_user ?? 0,
        supplierId: supplierId,
      );

      if (rules == null || rules.isEmpty) return;

      final ruleForSupplier = rules.firstWhere(
        (rule) => rule.productProvider?.id_product_provider == supplierId,
        orElse: () => rules.first,
      );

      final success = await personnelNotifier.updateTeamMemberPrivileges(
        ruleId: ruleForSupplier.id_management_rule,
        userId: user.id_app_user ?? 0,
        supplierId: supplierId,
        orgId: orgId,
        privilege: privileges,
      );

      if (context.mounted) {
        final localizations = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? localizations.privilegesUpdatedMessage(user.personFirstName)
                  : localizations.privilegesUpdateFailedMessage,
            ),
            backgroundColor: success ? colorScheme.tertiary : colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        onRefresh();
      }
    } catch (e) {
      debugPrint('Error modifying user privileges: $e');
    }
  }
}
