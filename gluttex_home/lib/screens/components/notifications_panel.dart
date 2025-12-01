// notifications_panel.dart
import 'package:flutter/material.dart';
import 'package:gluttex_core/app/Notifications/GluttexNotification.dart';
import 'package:gluttex_event/notification_notifier.dart';
import 'package:gluttex_home/screens/components/NotificationAction.dart';
import 'package:gluttex_home/screens/components/notification_item.dart';
import 'package:provider/provider.dart';

class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) {
        final unreadCount = notifier.unreadCount;
        final notifications = notifier.sortedByDate;

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Notifications',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Badge(
                      backgroundColor: colorScheme.error,
                      label: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      isLabelVisible: unreadCount > 0,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Notifications List
              Expanded(
                child: notifier.isLoading && notifications.isEmpty
                    ? _buildLoadingIndicator()
                    : notifications.isNotEmpty
                        ? _buildNotificationsList(
                            context, notifier, notifications)
                        : _buildEmptyNotifications(context),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: unreadCount > 0
                            ? () async {
                                await notifier.markAllAsRead();
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text('Mark All as Read'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Navigate to full notifications screen
                        },
                        child: const Text('View All'),
                      ),
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildNotificationsList(BuildContext context,
      NotificationNotifier notifier, List<GluttexNotification> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length.clamp(0, 5), // Show max 5 in preview
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => NotificationItem(
        notification: notifications[index],
        onMarkAsRead: () =>
            notifier.markAsRead(notifications[index].idNotification),
        // onDismiss: () =>
        //     notifier.dismissNotification(notifications[index].idNotification),
        // onAction: (action) => _handleNotificationAction(context, action),
      ),
    );
  }

  // void _handleAcceptRoleInvitation(NotificationAction action) {
  //   final ruleId = action.metadata['rule_id'];
  //   notifier.acceptRoleInvitation(action.notificationId, ruleId);

  //   // Show success feedback
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Role invitation accepted')),
  //   );
  // }

  // void _handleRejectRoleInvitation(NotificationAction action) {
  //   final ruleId = action.metadata['rule_id'];
  //   notifier.rejectRoleInvitation(action.notificationId, ruleId);

  //   // Show feedback
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Role invitation rejected')),
  //   );
  // }

  // void _handleViewNotification(NotificationAction action) {
  //   // Navigate to notification details
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => NotificationDetailsPage(
  //         notificationId: action.notificationId,
  //       ),
  //     ),
  //   );
  // }

  // void _handleReplyToMessage(NotificationAction action) {
  //   // Open reply dialog or navigate to chat
  //   showDialog(
  //     context: context,
  //     builder: (context) => ReplyDialog(notificationId: action.notificationId),
  //   );
  // }

  Widget _buildNotificationItem(BuildContext context,
      NotificationNotifier notifier, GluttexNotification notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          if (!notification.isRead) {
            await notifier.markAsRead(notification.idNotification);
          }
          // TODO: Handle notification specific action
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? colorScheme.surfaceVariant.withOpacity(0.3)
                : colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification, colorScheme),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNotificationIcon(notification),
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getNotificationTitle(notification),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getNotificationMessage(notification),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimeAgo(notification.effectiveDate),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications(
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(
      GluttexNotification notification, ColorScheme colorScheme) {
    if (notification.requiresAction) {
      return colorScheme.error;
    }

    switch (notification.notificationCode) {
      case 'role_invitation':
        return colorScheme.primary;
      case 'system_alert':
        return colorScheme.secondary;
      case 'message':
        return colorScheme.tertiary;
      default:
        return colorScheme.primary;
    }
  }

  IconData _getNotificationIcon(GluttexNotification notification) {
    switch (notification.notificationCode) {
      case 'role_invitation':
        return Icons.person_add_rounded;
      case 'system_alert':
        return Icons.warning_rounded;
      case 'message':
        return Icons.message_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _getNotificationTitle(GluttexNotification notification) {
    switch (notification.notificationCode) {
      case 'role_invitation':
        return 'Role Invitation';
      case 'system_alert':
        return 'System Alert';
      case 'message':
        return 'New Message';
      default:
        return 'Notification';
    }
  }

  String _getNotificationMessage(GluttexNotification notification) {
    if (notification.content != null) {
      return notification.content.toString();
    }
    return 'You have a new notification';
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${difference.inDays ~/ 7}w ago';
  }
}
