import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/business/role_bit_mapper.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_personnel/privilege_ui.dart';

class SupplierUserCard extends StatelessWidget {
  final AppUser user;
  final bool isPending;
  final VoidCallback onManagePrivileges;
  final VoidCallback onRemove;
  final VoidCallback? onResendInvite;
  final VoidCallback? onCancelInvite;

  const SupplierUserCard({
    super.key,
    required this.user,
    this.isPending = false,
    required this.onManagePrivileges,
    required this.onRemove,
    this.onResendInvite,
    this.onCancelInvite,
  });

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
          color: isPending
              ? Colors.orange.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.1),
          width: isPending ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPending
                ? Colors.orange.withOpacity(0.1)
                : colorScheme.shadow.withOpacity(0.1),
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
                // Avatar with Status Badge
                Stack(
                  children: [
                    _buildAvatar(context),
                    if (isPending)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name with pending indicator
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${user.personFirstName ?? ''} ${user.personLastName ?? ''}',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    if (isPending)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            localizations.pendingTxt,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.app_user_name ?? 'No username',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Email if available
                      if (user.app_user_name?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.app_user_name!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Privilege Tags (only for active users)
                      if (!isPending)
                        _buildPrivilegeTags(context, localizations),
                      // Additional status info for pending users
                      if (isPending)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    localizations.pendingInvitationMessage,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Role Badge with status indicator
                _buildRoleBadgeWithStatus(context, isPending),
              ],
            ),
          ),
          // Actions - Different actions for pending vs active users
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isPending
                  ? Colors.orange.withOpacity(0.05)
                  : colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: isPending
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.transparent,
              ),
            ),
            child: _buildActionButtons(context, localizations, isPending),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: user.app_user_image_url != null
            ? DecorationImage(
                image: NetworkImage(user.app_user_image_url!),
                fit: BoxFit.cover,
              )
            : null,
        color: user.app_user_image_url == null
            ? colorScheme.primary.withOpacity(0.1)
            : null,
      ),
      child: user.app_user_image_url == null
          ? Center(
              child: Text(
                '${user.personFirstName?[0] ?? ''}${user.personLastName?[0] ?? ''}'
                    .toUpperCase(),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRoleBadgeWithStatus(BuildContext context, bool isPending) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: user.isAdmin
                ? Colors.red.withOpacity(0.1)
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            user.isAdmin ? 'Admin' : user.app_user_type_desc ?? 'Member',
            style: theme.textTheme.labelSmall?.copyWith(
              color:
                  user.isAdmin ? Colors.red : colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Status indicator
        if (isPending)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Pending',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, AppLocalizations localizations, bool isPending) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isPending) {
      // For pending users: Show resend and cancel options
      return Row(
        children: [
          // Expanded(
          //   child: _buildActionButton(
          //     context: context,
          //     icon: Icons.refresh,
          //     text: localizations.actionResendInvite,
          //     onTap: () {
          //       if (onResendInvite != null) {
          //         onResendInvite!();
          //       }
          //     },
          //     color: Colors.orange,
          //     backgroundColor: Colors.orange.withOpacity(0.1),
          //   ),
          // ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              context: context,
              icon: Icons.cancel_outlined,
              text: localizations.actionCancelInvite,
              onTap: () {
                if (onCancelInvite != null) {
                  onCancelInvite!();
                }
              },
              color: colorScheme.error,
              backgroundColor: colorScheme.error.withOpacity(0.1),
            ),
          ),
        ],
      );
    } else {
      // For active users: Show manage and notify options
      return Row(
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
              onTap: () {
                _showNotificationOptions(context);
              },
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
      );
    }
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color color,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Send Message'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement message sending
                },
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Send Email'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement email sending
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Send Notification'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement push notification
                },
              ),
            ],
          ),
        );
      },
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
    // If user has privilege bitmask in their data
    // if (user.privilege != null) {
    //   return RoleBitMapper.numberToPrivilegeIds(user.privilege!);
    // }

    // // If user has privileges directly in their data
    // if (user.privileges != null && user.privileges!.isNotEmpty) {
    //   return user.privileges!;
    // }

    return [];
  }

  Color _getPrivilegeColor(String privilegeId, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Map privilege IDs to colors
    if (privilegeId.contains('inventory')) {
      return colorScheme.primary;
    } else if (privilegeId.contains('orders')) {
      return colorScheme.secondary;
    } else if (privilegeId.contains('personnel')) {
      return colorScheme.tertiary;
    } else if (privilegeId.contains('admin') ||
        privilegeId.contains('full_access')) {
      return colorScheme.error;
    }

    return colorScheme.outline;
  }

  // Add localization strings to your AppLocalizations class
  // In your ARB files or localization class:
  // String get statusPending => 'Pending';
  // String get pendingInvitationMessage => 'Awaiting user acceptance';
  // String get actionResendInvite => 'Resend';
  // String get actionCancelInvite => 'Cancel';
  // String get resendInvitation => 'Resend Invitation';
  // String get resendInvitationConfirmation(String name) => 'Resend invitation to $name?';
  // String get invitationResent => 'Invitation resent';
  // String get cancelInvitation => 'Cancel Invitation';
  // String get cancelInvitationConfirmation(String name) => 'Cancel invitation to $name? This action cannot be undone.';
  // String get confirmCancel => 'Cancel Invite';
  // String get invitationCanceled => 'Invitation canceled';
}
