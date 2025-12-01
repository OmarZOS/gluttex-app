import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/business/role_bit_mapper.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_personnel/privilege_ui.dart';

class SupplierUserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onManagePrivileges;
  final VoidCallback onRemove;
  final int?
      privilegesBitmask; // Optional: If you have the bitmask for this user
  final int? supplierId; // Optional: For context-specific privileges

  const SupplierUserCard({
    Key? key,
    required this.user,
    required this.onManagePrivileges,
    required this.onRemove,
    this.privilegesBitmask,
    this.supplierId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Role Badge
                _buildAvatarWithBadge(context),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Username
                      _buildUserInfo(context),
                      const SizedBox(height: 8),
                      // Privilege Tags
                      _buildPrivilegeTags(context, localizations),
                      // Status Badge (if applicable)
                      if (_getRuleStatus(context) != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildStatusBadge(context),
                        ),
                    ],
                  ),
                ),
                // Role Badge
                _buildRoleBadge(context),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.admin_panel_settings,
                    text: localizations.actionManagePermissions,
                    onTap: onManagePrivileges,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.notifications,
                    text: localizations.actionNotify,
                    onTap: () {}, // Implement notification
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                _buildIconButton(
                  context: context,
                  icon: Icons.delete_outline,
                  onTap: onRemove,
                  color: colorScheme.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 2,
            ),
            image: user.app_user_image_url != null &&
                    user.app_user_image_url!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(user.app_user_image_url!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: user.app_user_image_url == null
                ? colorScheme.primaryContainer
                : null,
          ),
          child: user.app_user_image_url == null
              ? Icon(
                  Icons.person,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                )
              : null,
        ),
        if (user.isAdmin)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.shield,
                color: colorScheme.onError,
                size: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(
          '${user.personFirstName ?? ''} ${user.personLastName ?? ''}'.trim(),
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // Username
        if (user.app_user_name != null && user.app_user_name!.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.alternate_email_rounded,
                size: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '@${user.app_user_name!}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPrivilegeTags(
      BuildContext context, AppLocalizations localizations) {
    final colorScheme = Theme.of(context).colorScheme;
    final privilegeIds = _getUserPrivilegeIds();

    if (privilegeIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          localizations.roleNoPrivileges,
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: privilegeIds.take(3).map((privilegeId) {
        final privilegeUI = PrivilegeUIManager.getPrivilege(privilegeId);
        final title = privilegeUI?.getTitle(context) ?? privilegeId;
        final color = _getPrivilegeColor(privilegeId, context);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                privilegeUI?.icon ?? Icons.check_circle_outline,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final role = _getUserRole(localizations);
    final color = _getRoleColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            role,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _getRuleStatus(context);
    if (status == null) return const SizedBox.shrink();

    final isActive = status.toUpperCase() == RuleStates.active;
    final isPending = status.toUpperCase() == RuleStates.pending;
    final isRejected = status.toUpperCase() == RuleStates.rejected;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isActive) {
      statusColor = colorScheme.tertiary;
      statusIcon = Icons.check_circle;
      statusText = 'Active';
    } else if (isPending) {
      statusColor = colorScheme.secondary;
      statusIcon = Icons.access_time;
      statusText = 'Pending';
    } else if (isRejected) {
      statusColor = colorScheme.error;
      statusIcon = Icons.cancel;
      statusText = 'Rejected';
    } else {
      statusColor = colorScheme.outline;
      statusIcon = Icons.help_outline;
      statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surface,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surface,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  // Helper methods

  List<String> _getUserPrivilegeIds() {
    if (privilegesBitmask != null) {
      return RoleBitMapper.numberToPrivilegeIds(privilegesBitmask!);
    }
    // If no bitmask provided, check user's privileges
    // You might need to access user.privileges or similar
    return [];
  }

  String _getUserRole(AppLocalizations localizations) {
    final privilegeCount = _getUserPrivilegeIds().length;

    if (user.isAdmin) {
      return localizations.roleAdmin;
    } else if (privilegeCount >= 4) {
      return localizations.roleManager;
    } else if (privilegeCount >= 2) {
      return localizations.roleSupervisor;
    } else if (privilegeCount >= 1) {
      return localizations.roleStaff;
    }

    return localizations.roleViewer;
  }

  Color _getRoleColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final privilegeCount = _getUserPrivilegeIds().length;

    if (user.isAdmin) {
      return colorScheme.error;
    } else if (privilegeCount >= 4) {
      return colorScheme.primary;
    } else if (privilegeCount >= 2) {
      return colorScheme.secondary;
    } else if (privilegeCount >= 1) {
      return colorScheme.tertiary;
    }

    return colorScheme.outline;
  }

  IconData _getRoleIcon() {
    final privilegeCount = _getUserPrivilegeIds().length;

    if (user.isAdmin) {
      return Icons.security;
    } else if (privilegeCount >= 4) {
      return Icons.manage_accounts;
    } else if (privilegeCount >= 2) {
      return Icons.supervisor_account;
    } else if (privilegeCount >= 1) {
      return Icons.badge;
    }

    return Icons.visibility;
  }

  Color _getPrivilegeColor(String privilegeId, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (privilegeId) {
      case RoleTypes.inventory_view:
      case RoleTypes.inventory_manage:
        return colorScheme.primary;
      case RoleTypes.orders_view:
      case RoleTypes.orders_manage:
        return colorScheme.secondary;
      case RoleTypes.personnel_view:
      case RoleTypes.personnel_manage:
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }

  String? _getRuleStatus(BuildContext context) {
    // This depends on your data structure
    // You might need to get this from user.privileges or context
    // For example:
    // final rule = context.read<PersonnelNotifier>().getRuleForUser(user.id_app_user, supplierId);
    // return rule?.ruleStatus;
    return null; // Implement based on your data
  }
}
