import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Notifications/GluttexNotification.dart';
import 'package:gluttex_core/app/Notifications/Notifications/RoleInvitation.dart';
import 'package:gluttex_core/business/role_bit_mapper.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_home/screens/components/NotificationAction.dart';
import 'package:gluttex_personnel/privilege_ui.dart';
import 'package:provider/provider.dart';

class NotificationItem extends StatelessWidget {
  static const _animationDuration = Duration(milliseconds: 300);
  static const _containerAnimationDuration = Duration(milliseconds: 400);
  static const _borderRadius = 24.0;
  static const _compactPadding = EdgeInsets.all(16);
  static const _regularPadding = EdgeInsets.all(20);
  static const _margin = EdgeInsets.symmetric(vertical: 6, horizontal: 0);

  final GluttexNotification notification;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDismiss;
  final Function(NotificationAction)? onAction;
  final bool isCompact;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onMarkAsRead,
    this.onDismiss,
    this.onAction,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AnimatedSize(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: () => _handleTap(context),
          onLongPress: _handleLongPress,
          splashColor: colorScheme.primary.withOpacity(0.15),
          highlightColor: colorScheme.primary.withOpacity(0.08),
          child: AnimatedContainer(
            duration: _containerAnimationDuration,
            curve: Curves.fastEaseInToSlowEaseOut,
            padding: isCompact ? _compactPadding : _regularPadding,
            margin: _margin,
            decoration: BoxDecoration(
              gradient: _getBackgroundGradient(context),
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(
                color: notification.isRead
                    ? colorScheme.outline.withOpacity(0.08)
                    : colorScheme.primary.withOpacity(0.2),
                width: notification.isRead ? 1 : 1.2,
              ),
              boxShadow: _getBoxShadows(colorScheme),
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        if (!isCompact) ...[
          const SizedBox(height: 16),
          _buildMessage(context),
          const SizedBox(height: 16),
        ],
        _buildFooter(context),
      ],
    );
  }

  List<BoxShadow> _getBoxShadows(ColorScheme colorScheme) {
    return [
      if (!notification.isRead)
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0.5,
        ),
      BoxShadow(
        color: colorScheme.onSurface.withOpacity(0.02),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  void _handleTap(BuildContext context) {
    HapticFeedback.lightImpact();

    if (!notification.isRead) {
      onMarkAsRead?.call();
    }

    // Use Future.microtask to handle async operations after build
    Future.microtask(() async {
      final defaultAction = await _getDefaultAction(context);
      if (defaultAction != null) {
        onAction?.call(defaultAction);
      }
    });
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
  }

  Widget _buildHeader(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserImageUrl(context),
      builder: (context, snapshot) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(context, snapshot.data),
            const SizedBox(width: 16),
            Expanded(
              child: _buildHeaderContent(context),
            ),
            if (onDismiss != null) _buildDismissButton(context),
          ],
        );
      },
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _getNotificationTitle(localizations),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!notification.isRead) _buildUnreadIndicator(context),
          ],
        ),
        _buildSubtitle(context, localizations),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, AppLocalizations localizations) {
    return FutureBuilder<String?>(
      future: _getNotificationSubtitle(context, localizations),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              snapshot.data!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNotificationIcon(BuildContext context, String? userImageUrl) {
    final isRoleInvitation = notification.content?.type == 'role_invitation';

    if (isRoleInvitation && userImageUrl != null && userImageUrl.isNotEmpty) {
      return _buildUserAvatar(context, userImageUrl);
    }

    return FutureBuilder<IconData>(
      future: _getNotificationIcon(),
      builder: (context, snapshot) {
        return _buildIconWidget(
            context, snapshot.data ?? Icons.notifications_rounded);
      },
    );
  }

  Widget _buildUserAvatar(BuildContext context, String imageUrl) {
    final theme = Theme.of(context);
    final size = isCompact ? 36.0 : 44.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildAvatarPlaceholder(theme, Icons.person);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildAvatarPlaceholder(theme, Icons.error_outline);
          },
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(ThemeData theme, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
    );
  }

  Widget _buildIconWidget(BuildContext context, IconData icon) {
    final size = isCompact ? 36.0 : 44.0;
    final iconSize = isCompact ? 18.0 : 22.0;

    return AnimatedContainer(
      duration: _animationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getNotificationColor(context),
        borderRadius: BorderRadius.circular(14),
        gradient: _getNotificationGradient(context),
        boxShadow: [
          BoxShadow(
            color: _getNotificationColor(context).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onPrimary,
        size: iconSize,
      ),
    );
  }

  Future<String?> _getUserImageUrl(BuildContext context) async {
    if (notification.content?.type != 'role_invitation') {
      return null;
    }

    final addedBy = notification.content!.addedBy?.toString();
    if (addedBy == null || addedBy.isEmpty) {
      return null;
    }

    try {
      final notifier = context.read<AppUserNotifier>();
      final appUser = await notifier.fetchUserPassively(addedBy);
      return appUser?.app_user_image_url;
    } catch (error) {
      debugPrint('Error fetching user image: $error');
      return null;
    }
  }

  Future<IconData> _getNotificationIcon() async {
    switch (notification.content?.type) {
      case 'order_received':
        return Icons.shopping_bag_rounded;
      case 'role_invitation':
        return Icons.people_alt_rounded;
      case 'product_updated':
        return Icons.inventory_2_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Widget _buildMessage(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FutureBuilder<String>(
      future: _getNotificationMessage(context, localizations),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
              height: 1.5,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.1,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      children: [
        AnimatedOpacity(
          duration: _animationDuration,
          opacity: 0.8,
          child: Text(
            _formatTimeAgo(notification.content!.timestamp, localizations),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        const Spacer(),
        Consumer<PersonnelNotifier>(
          builder: (context, personnel, _) {
            return _buildActions(context, localizations);
          },
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations localizations) {
    return FutureBuilder<List<NotificationAction>>(
      future: _getAvailableActions(context, localizations),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final actions = snapshot.data ?? [];
        if (actions.isEmpty) return const SizedBox.shrink();

        return AnimatedSwitcher(
          duration: _animationDuration,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions
                .map((action) => _buildActionButton(context, action))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, NotificationAction action) {
    final theme = Theme.of(context);

    return FilledButton.tonal(
      onPressed: () => _handleActionPress(context, action),
      style: FilledButton.styleFrom(
        backgroundColor: _getActionColor(context, action.type),
        foregroundColor: _getActionTextColor(context, action.type),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: -0.1,
        ),
      ),
      child: _buildActionContent(action),
    );
  }

  Widget _buildActionContent(NotificationAction action) {
    final icon = _getActionIcon(action.type);
    if (icon == null) {
      return Text(action.label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(action.label),
      ],
    );
  }

  void _handleActionPress(BuildContext context, NotificationAction action) {
    HapticFeedback.selectionClick();
    NotificationActionHandler.handle(context, action);
  }

  Widget _buildUnreadIndicator(BuildContext context) {
    return AnimatedContainer(
      duration: _animationDuration,
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissButton(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        onDismiss?.call();
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      splashRadius: 20,
    );
  }

  // Content helper methods
  Color _getNotificationColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (notification.content?.type) {
      case 'order_received':
        return colorScheme.primary;
      case 'role_invitation':
        return colorScheme.secondary;
      case 'product_updated':
        return colorScheme.tertiary;
      default:
        return colorScheme.surface;
    }
  }

  Gradient _getBackgroundGradient(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (notification.isRead) {
      return LinearGradient(
        colors: [
          colorScheme.surfaceVariant.withOpacity(0.3),
          colorScheme.surface.withOpacity(0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return LinearGradient(
        colors: [
          colorScheme.primaryContainer.withOpacity(0.1),
          colorScheme.surfaceVariant.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Gradient _getNotificationGradient(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (notification.content?.type) {
      case 'order_received':
        return LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        );
      case 'role_invitation':
        return LinearGradient(
          colors: [colorScheme.secondary, colorScheme.secondaryContainer],
        );
      case 'product_updated':
        return LinearGradient(
          colors: [colorScheme.tertiary, colorScheme.tertiaryContainer],
        );
      default:
        return LinearGradient(
          colors: [colorScheme.surfaceVariant, colorScheme.outline],
        );
    }
  }

  String _getNotificationTitle(AppLocalizations localizations) {
    switch (notification.content?.type) {
      case 'order_received':
        return localizations.notificationOrderReceivedTitle;
      case 'role_invitation':
        return localizations.notificationRoleInvitationTitle;
      case 'product_updated':
        return localizations.notificationProductUpdatedTitle;
      default:
        return notification.content?.displayTitle ??
            localizations.notificationDefaultTitle;
    }
  }

  Future<String?> _getNotificationSubtitle(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    if (notification.content is RoleInvitation) {
      final invitation = notification.content as RoleInvitation;
      final supplier = await context
          .read<SupplierChangeNotifier>()
          .getSupplierById(invitation.providerId);

      final roleName = _getRoleName(invitation.role, localizations);
      return '${supplier?.provider_organisation_name} • ${supplier?.providerName}';
    }

    switch (notification.content?.type) {
      case 'order_received':
        return localizations.notificationOrderReceivedSubtitle;
      case 'product_updated':
        return localizations.notificationProductUpdatedSubtitle;
      default:
        return null;
    }
  }

  String _getRoleName(int role, AppLocalizations localizations) {
    return RoleBitMapper.numberToPrivilegeIds(role).toString();
  }

  Future<String> _getNotificationMessage(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    switch (notification.content?.type) {
      case 'order_received':
        return localizations.notificationOrderReceivedMessage;
      case 'role_invitation':
        if (notification.content is RoleInvitation) {
          final invitation = notification.content as RoleInvitation;
          final privileges =
              RoleBitMapper.numberToPrivilegeItems(invitation.role);
          final privilegeTitles = privileges
              .map((privilege) =>
                  PrivilegeUIManager.getPrivilege(privilege.id)
                      ?.getTitle(context) ??
                  privilege.id)
              .join(', ');

          final appUser = await _fetchUserResponsible(context);
          final userName = appUser != null
              ? "${appUser.personFirstName} ${appUser.personLastName}".trim()
              : "unknownUser";

          return localizations.notificationRoleInvitationMessage(
              userName, privilegeTitles);
        }
        return localizations.notificationRoleInvitationDefaultMessage;
      case 'product_updated':
        return localizations.notificationProductUpdatedMessage;
      default:
        return notification.content?.displayMessage ??
            localizations.notificationDefaultMessage;
    }
  }

  String _formatTimeAgo(DateTime date, AppLocalizations localizations) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return localizations.timeJustNow;
    if (difference.inMinutes < 60)
      return localizations.timeMinutesAgo(difference.inMinutes);
    if (difference.inHours < 24)
      return localizations.timeHoursAgo(difference.inHours);
    if (difference.inDays < 7)
      return localizations.timeDaysAgo(difference.inDays);
    if (difference.inDays < 30)
      return localizations.timeWeeksAgo((difference.inDays / 7).floor());

    return localizations.timeDate(date.day, date.month, date.year);
  }

  Future<List<NotificationAction>> _getAvailableActions(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    switch (notification.content?.type) {
      case 'order_received':
        return [
          NotificationAction(
            type: ActionType.view,
            label: localizations.actionTrackOrder,
            notificationId: notification.idNotification,
          ),
          // NotificationAction(
          //   type: ActionType.download,
          //   label: localizations.actionDownloadInvoice,
          //   notificationId: notification.idNotification,
          // ),
        ];

      case 'role_invitation':
        return await _buildRoleInvitationActions(context, localizations);

      case 'product_updated':
        return [
          NotificationAction(
            type: ActionType.view,
            label: localizations.actionSeeChanges,
            notificationId: notification.idNotification,
          ),
          NotificationAction(
            type: ActionType.download,
            label: localizations.actionUpdateNow,
            notificationId: notification.idNotification,
          ),
        ];

      default:
        return [
          NotificationAction(
            type: ActionType.view,
            label: localizations.actionViewDetails,
            notificationId: notification.idNotification,
          ),
        ];
    }
  }

  Future<List<NotificationAction>> _buildRoleInvitationActions(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    final invitation = notification.content as RoleInvitation?;
    if (invitation == null) return [];

    try {
      // Fix: The getUserPrivileges method signature might be wrong
      // Based on your earlier code, it should be: getUserPrivileges(userId, {supplierId = 0})
      final privileges = await context
          .read<PersonnelNotifier>()
          .getUserPrivileges(
              ruleId: invitation.ruleId,
              userId: invitation.addedBy,
              supplierId: invitation.providerId);
      debugPrint(privileges.toString());
      // Debug: Print all privileges to see the structure
      debugPrint("=== DEBUG PRIVILEGES ===");
      debugPrint("Invitation providerId: ${invitation.providerId}");
      debugPrint("Invitation ruleId: ${invitation.ruleId}");
      debugPrint("Invitation addedBy: ${invitation.addedBy}");

      if (privileges != null) {
        for (final rule in privileges) {
          debugPrint(
              "Rule: id=${rule.id_management_rule}, status=${rule.ruleStatus}, providerId=${rule.productProvider?.id_product_provider}");
        }
      } else {
        debugPrint("No privileges found for user ${invitation.addedBy}");
      }
      debugPrint("=== END DEBUG ===");

      // Use where + firstOrNull pattern
      final targetedRule = privileges
          ?.where((item) => item.id_management_rule == invitation.ruleId)
          .firstOrNull;

      debugPrint("Targeted rule: $targetedRule");
      debugPrint("Rule status: ${targetedRule?.ruleStatus}");

      // If no rule found, assume it's pending (new invitation)
      final ruleStatus = targetedRule?.ruleStatus ?? RuleStates.pending;
      final isPending = ruleStatus.toUpperCase() == RuleStates.pending;
      final isActive = ruleStatus.toUpperCase() == RuleStates.active;

      final actions = <NotificationAction>[];

      if (isPending) {
        actions.addAll([
          NotificationAction(
            type: ActionType.accept,
            label: localizations.actionAccept,
            notificationId: notification.idNotification,
            metadata: {
              'rule_id': invitation.ruleId,
              'organization_id': invitation.organizationId,
              'provider_id': invitation.providerId,
              'role': invitation.role,
            },
          ),
          NotificationAction(
            type: ActionType.reject,
            label: localizations.actionDecline,
            notificationId: notification.idNotification,
            metadata: {
              'rule_id': invitation.ruleId,
              'organization_id': invitation.organizationId,
              'provider_id': invitation.providerId,
            },
          ),
        ]);
      }

      if (isActive) {
        actions.add(NotificationAction(
          type: ActionType.view,
          label: localizations.actionViewTeam,
          notificationId: notification.idNotification,
          metadata: {
            'organization_id': invitation.organizationId,
            'provider_id': invitation.providerId,
          },
        ));
      }

      return actions;
    } catch (e) {
      debugPrint('Error building role invitation actions: $e');
      return [];
    }
  }

  Future<AppUser?> _fetchUserResponsible(BuildContext context) async {
    final addedBy = notification.content?.addedBy;
    if (addedBy == null || addedBy == 0) return null;

    try {
      final userNotifier = context.read<AppUserNotifier>();
      return await userNotifier.fetchUserPassively(addedBy.toString());
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  Future<NotificationAction?> _getDefaultAction(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final actions = await _getAvailableActions(context, localizations!);
    return actions.isNotEmpty ? actions.first : null;
  }

  Color _getActionColor(BuildContext context, ActionType type) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (type) {
      case ActionType.accept:
        return colorScheme.primary;
      case ActionType.reject:
        return colorScheme.error;
      case ActionType.download:
        return colorScheme.tertiary;
      case ActionType.view:
        return colorScheme.secondary;
      default:
        return colorScheme.surfaceVariant;
    }
  }

  Color _getActionTextColor(BuildContext context, ActionType type) {
    final colorScheme = Theme.of(context).colorScheme;
    return type.index <= ActionType.view.index
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
  }

  IconData? _getActionIcon(ActionType type) {
    switch (type) {
      case ActionType.accept:
        return Icons.check_rounded;
      case ActionType.reject:
        return Icons.close_rounded;
      case ActionType.download:
        return Icons.download_rounded;
      case ActionType.view:
        return Icons.visibility_rounded;
      default:
        return null;
    }
  }
}
