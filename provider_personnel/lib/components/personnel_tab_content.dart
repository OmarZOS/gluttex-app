import 'package:flutter/material.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:provider_personnel/components/supplier_user_card.dart';
import 'package:event/personnel_notifier.dart';
import 'package:provider/provider.dart';

class PersonnelTabContent extends StatelessWidget {
  final int supplierId;
  final bool includePending;
  final RefreshCallback onRefresh;
  final Function onShowPrivilegeDialog;
  final Function onShowRemoveDialog;
  final Function onCancelInvitation;

  const PersonnelTabContent({
    super.key,
    required this.supplierId,
    required this.includePending,
    required this.onRefresh,
    required this.onShowPrivilegeDialog,
    required this.onShowRemoveDialog,
    required this.onCancelInvitation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, _) {
        final users = notifier.getPersonnelForSupplier(
          supplierId,
          includePending: includePending,
        );

        final filteredUsers = includePending
            ? users
            : users.where((user) {
                final userId = user.id_app_user ?? 0;
                return !notifier.hasPendingRulesForSupplier(userId, supplierId);
              }).toList();

        if (notifier.isLoading && filteredUsers.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (filteredUsers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    includePending ? Icons.people_outline : Icons.check_circle,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    includePending ? 'No Team Members' : 'No Active Members',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final isPending = notifier.hasPendingRulesForSupplier(
                user.id_app_user ?? 0,
                supplierId,
              );

              ManagementRule? rule;
              if (isPending) {
                rule = notifier
                    .getPendingRulesForUser(
                      user.id_app_user ?? 0,
                      supplierId: supplierId,
                    )
                    .firstOrNull;
              } else {
                rule = notifier
                    .getRulesForUser(
                      user.id_app_user ?? 0,
                      supplierId: supplierId,
                    )
                    .firstOrNull;
              }

              return SupplierUserCard(
                user: user,
                supplierId: supplierId,
                isPending: isPending,
                ruleCode: rule?.management_rule_code ?? 0,
                onManagePrivileges: () => onShowPrivilegeDialog(
                    user, isPending, rule?.id_management_rule),
                onRemove: () =>
                    onShowRemoveDialog(rule?.id_management_rule, user),
                // onResendInvite:
                //     isPending ? () => onResendInvitation(user) : null,
                onCancelInvite: isPending
                    ? () => onCancelInvitation(user, rule?.id_management_rule)
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
