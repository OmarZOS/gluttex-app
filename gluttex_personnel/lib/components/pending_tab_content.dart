import 'package:flutter/material.dart';
import 'package:gluttex_personnel/components/supplier_user_card.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:provider/provider.dart';

class PendingTabContent extends StatelessWidget {
  final int supplierId;
  final String supplierName;
  final RefreshCallback onRefresh;
  final Function onShowPrivilegeDialog;
  final Function onShowRemoveDialog;
  final Function onCancelInvitation;
  final VoidCallback onShowAddOptions;

  const PendingTabContent({
    required this.supplierId,
    required this.supplierName,
    required this.onRefresh,
    required this.onShowPrivilegeDialog,
    required this.onShowRemoveDialog,
    required this.onCancelInvitation,
    required this.onShowAddOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, _) {
        final allUsers = notifier.getPersonnelForSupplier(
          supplierId,
          includePending: true,
        );

        final pendingUsers = allUsers.where((user) {
          final userId = user.id_app_user ?? 0;
          return notifier.hasPendingRulesForSupplier(userId, supplierId);
        }).toList();

        if (notifier.isLoading && pendingUsers.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (pendingUsers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Pending Invitations',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All invitations have been accepted or no pending invites exist.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: onShowAddOptions,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Invite New Member'),
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
            itemCount: pendingUsers.length,
            itemBuilder: (context, index) {
              final user = pendingUsers[index];
              final pendingRule = notifier
                  .getPendingRulesForUser(
                    user.id_app_user ?? 0,
                    supplierId: supplierId,
                  )
                  .firstOrNull;

              return SupplierUserCard(
                user: user,
                supplierId: supplierId,
                ruleCode: pendingRule?.management_rule_code ?? 0,
                isPending: true,
                onManagePrivileges: () => onShowPrivilegeDialog(user, true),
                onRemove: () =>
                    onShowRemoveDialog(pendingRule?.id_management_rule, user),
                // onResendInvite: () => onResendInvitation(user),
                onCancelInvite: () =>
                    onCancelInvitation(user, pendingRule?.id_management_rule),
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
