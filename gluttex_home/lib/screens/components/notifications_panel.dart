// notifications_panel.dart
import 'package:flutter/material.dart';
import 'package:gluttex_core/app/Notifications/GluttexNotification.dart';
import 'package:gluttex_event/notification_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_home/screens/components/NotificationAction.dart';
import 'package:gluttex_home/screens/components/notification_item.dart';
import 'package:provider/provider.dart';

class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({super.key});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // Load notifications when panel opens
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNotifications();
      });
    }
  }

  Future<void> _loadNotifications() async {
    final userNotifier = context.read<AppUserNotifier>();
    final notifier = context.read<NotificationNotifier>();

    final currentUserId = userNotifier.appUser?.id_app_user;
    if (currentUserId != null && currentUserId > 0) {
      await notifier.loadInitialNotifications(currentUserId);
    }
  }

  Future<void> _refreshNotifications() async {
    final userNotifier = context.read<AppUserNotifier>();
    final notifier = context.read<NotificationNotifier>();

    final currentUserId = userNotifier.appUser?.id_app_user;
    if (currentUserId != null && currentUserId > 0) {
      await notifier.refreshNotifications(currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) {
        final unreadCount = notifier.unreadCount;
        final notifications = notifier.sortedByDate;
        final isLoading = notifier.isLoading;
        final error = notifier.error;

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
              _buildHeader(context, notifier, unreadCount),
              // Content
              Expanded(
                child: _buildContent(
                  context,
                  notifier,
                  notifications,
                  isLoading,
                  error,
                ),
              ),
              // Footer Actions
              _buildFooter(context, notifier, unreadCount),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NotificationNotifier notifier,
    int unreadCount,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
          if (unreadCount > 0)
            Badge(
              backgroundColor: colorScheme.error,
              label: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              isLabelVisible: true,
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
    );
  }

  Widget _buildContent(
    BuildContext context,
    NotificationNotifier notifier,
    List<GluttexNotification> notifications,
    bool isLoading,
    String? error,
  ) {
    if (isLoading && notifications.isEmpty) {
      return _buildLoadingIndicator();
    }

    if (error != null && notifications.isEmpty) {
      return _buildErrorState(context, error, notifier);
    }

    if (notifications.isEmpty) {
      return _buildEmptyNotifications(context);
    }

    // Show max 5 in preview panel
    final displayNotifications =
        notifications.length > 5 ? notifications.sublist(0, 5) : notifications;

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: displayNotifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => NotificationItem(
          notification: displayNotifications[index],
          onMarkAsRead: () => notifier.markAsRead(
            displayNotifications[index].idNotification,
          ),
          onAction: (action) =>
              _handleNotificationAction(context, notifier, action),
        ),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    NotificationNotifier notifier,
    int unreadCount,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
              onPressed: unreadCount > 0 && !notifier.isLoading
                  ? () async {
                      await notifier.markAllAsRead();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All notifications marked as read'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  : null,
              child: notifier.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Mark All as Read'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: notifier.isLoading
                  ? null
                  : () {
                      Navigator.pop(context);
                      // TODO: Navigate to full notifications screen
                    },
              child: const Text('View All'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationAction(
    BuildContext context,
    NotificationNotifier notifier,
    NotificationAction action,
  ) {
    // Handle different action types
    switch (action.type) {
      case ActionType.accept:
        _handleAcceptAction(context, notifier, action);
        break;
      case ActionType.reject:
        _handleRejectAction(context, notifier, action);
        break;
      case ActionType.view:
        _handleViewAction(context, action);
        break;
      case ActionType.dismiss:
        _handleDismissAction(context, notifier, action);
        break;
      case ActionType.reply:
        _handleReplyAction(context, action);
        break;
      case ActionType.archive:
        _handleArchiveAction(context, notifier, action);
        break;
      case ActionType.download:
        _handleDownloadAction(context, action);
        break;
    }
  }

  void _handleAcceptAction(
    BuildContext context,
    NotificationNotifier notifier,
    NotificationAction action,
  ) {
    final ruleId = action.metadata?['rule_id'];
    if (ruleId != null) {
      // The actual acceptance is handled in NotificationItem's _handleActionPress
      // This is just for UI feedback after the action is completed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation accepted'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      // Refresh notifications to update the list
      Future.delayed(const Duration(milliseconds: 500), () {
        _refreshNotifications();
      });
    }
  }

  void _handleRejectAction(
    BuildContext context,
    NotificationNotifier notifier,
    NotificationAction action,
  ) {
    final ruleId = action.metadata?['rule_id'];
    if (ruleId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation declined'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      // Refresh notifications to update the list
      Future.delayed(const Duration(milliseconds: 500), () {
        _refreshNotifications();
      });
    }
  }

  void _handleViewAction(BuildContext context, NotificationAction action) {
    // Navigate based on notification type
    final metadata = action.metadata;
    if (metadata != null && metadata['organization_id'] != null) {
      // Navigate to organization/supplier details
      Navigator.pushNamed(
        context,
        '/supplier/manage',
        arguments: {
          'organization_id': metadata['organization_id'],
          'provider_id': metadata['provider_id'],
        },
      );
    }
  }

  void _handleDismissAction(
    BuildContext context,
    NotificationNotifier notifier,
    NotificationAction action,
  ) {
    // Just dismiss - notification is already handled
    debugPrint('Notification dismissed: ${action.notificationId}');
  }

  void _handleReplyAction(BuildContext context, NotificationAction action) {
    // Show reply dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Type your reply...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _handleArchiveAction(
    BuildContext context,
    NotificationNotifier notifier,
    NotificationAction action,
  ) {
    // Archive the notification
    notifier.deleteNotification(action.notificationId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification archived'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleDownloadAction(BuildContext context, NotificationAction action) {
    // Handle download
    final url = action.metadata?['url'];
    if (url != null) {
      // Implement download logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download started'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    NotificationNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshNotifications,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotifications(BuildContext context) {
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
            "You're all caught up!",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
