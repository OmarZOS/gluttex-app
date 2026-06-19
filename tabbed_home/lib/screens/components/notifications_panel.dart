// notifications_panel.dart
import 'package:flutter/material.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/Notifications/GluttexNotification.dart';
import 'package:event/notification_notifier.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:tabbed_home/screens/components/NotificationAction.dart';
import 'package:tabbed_home/screens/components/notification_item.dart';
import 'package:ui/Services/ResponseHandler.dart';
import 'package:provider/provider.dart';

class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({super.key});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNotifications();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final notifier = context.read<NotificationNotifier>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        notifier.hasMore &&
        !notifier.isLoading &&
        !_isLoadingMore) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    final userNotifier = context.read<AppUserNotifier>();
    final notifier = context.read<NotificationNotifier>();

    final currentUserId = userNotifier.appUser?.id_app_user;
    if (currentUserId != null && currentUserId > 0) {
      _currentPage = 0;
      await notifier.loadInitialNotifications(
        currentUserId,
        limit: _pageSize,
      );
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    final notifier = context.read<NotificationNotifier>();
    _currentPage++;
    await notifier.loadMoreNotifications(limit: _pageSize);

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshNotifications() async {
    final userNotifier = context.read<AppUserNotifier>();
    final notifier = context.read<NotificationNotifier>();
    final currentUserId = userNotifier.appUser?.id_app_user;
    if (currentUserId != null && currentUserId > 0) {
      _currentPage = 0;
      await notifier.refreshNotifications(
        currentUserId,
        limit: _pageSize,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      child: Consumer<NotificationNotifier>(
        builder: (context, notifier, child) {
          final unreadCount = notifier.unreadCount;
          final notifications = notifier.sortedByDate;
          final isLoading = notifier.isLoading;
          final error = notifier.error;
          final hasMore = notifier.hasMore;
          final totalCount = notifier.totalCount;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(context, notifier, unreadCount, totalCount),

              // Content
              Expanded(
                child: _buildContent(
                  context,
                  notifier,
                  notifications,
                  isLoading,
                  error,
                  hasMore,
                ),
              ),

              // Footer Actions
              if (notifications.isNotEmpty)
                _buildFooter(context, notifier, unreadCount),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NotificationNotifier notifier,
    int unreadCount,
    int totalCount,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (totalCount > 0)
                  Text(
                    '$totalCount total • ${unreadCount} unread',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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
    bool hasMore,
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

    // Show all notifications with pagination
    final hasMoreToShow = hasMore;

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: notifications.length + (hasMoreToShow ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            return _buildLoadMoreIndicator(notifier);
          }
          return NotificationItem(
            notification: notifications[index],
            onMarkAsRead: () => notifier.markAsRead(
              notifications[index].idNotification,
            ),
            onAction: (action) =>
                _handleNotificationAction(context, notifier, action),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(NotificationNotifier notifier) {
    if (!notifier.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No more notifications',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const SizedBox.shrink(),
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
      padding: const EdgeInsets.all(12),
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
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                visualDensity: VisualDensity.compact,
              ),
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
              child: notifier.isLoading && _isLoadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Mark All as Read'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                visualDensity: VisualDensity.compact,
              ),
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
  ) async {
    // Generate a unique caller key for this action
    final callerKey =
        'notification_action_${action.type}_${action.notificationId}_${DateTime.now().millisecondsSinceEpoch}';

    switch (action.type) {
      case ActionType.accept:
        await _handleAcceptAction(context, notifier, action, callerKey);
        break;
      case ActionType.reject:
        await _handleRejectAction(context, notifier, action, callerKey);
        break;
      case ActionType.view:
        _handleViewAction(context, action);
        break;
      case ActionType.dismiss:
        await _handleDismissAction(context, notifier, action, callerKey);
        break;
      case ActionType.reply:
        await _handleReplyAction(context, action, callerKey);
        break;
      case ActionType.archive:
        await _handleArchiveAction(context, notifier, action, callerKey);
        break;
      case ActionType.download:
        await _handleDownloadAction(context, action, callerKey);
        break;
    }
  }

  Future<void> _handleAcceptAction(
    BuildContext context,
    NotificationNotifier notifier,
    NotificationAction action,
    String callerKey,
  ) async {
    try {
      final personnelNotifier = context.read<PersonnelNotifier>();

      final success = await personnelNotifier.answerInvitation(
        ruleId: action.metadata['rule_id'],
        answer: 0,
        callerKey: callerKey,
      );

      if (success) {
        await notifier.markAsRead(action.notificationId);
        ResponseHandler.handleResponse(
          context: context,
          statusCode: 200,
          responseCode: 'INVITATION_ACCEPTED',
          finalMessage: 'Invitation accepted successfully',
        );
        await _refreshNotifications();
      } else {
        final response = personnelNotifier.getResponse(callerKey);
        ResponseHandler.handleResponse(
          context: context,
          statusCode: response?.statusCode ?? 500,
          responseCode: response?.responseCode ?? 'ACCEPT_FAILED',
          finalMessage: response?.message ?? 'Failed to accept invitation',
        );
      }
    } catch (e) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 500,
        responseCode: 'ACCEPT_ERROR',
        finalMessage: 'Error accepting invitation: $e',
      );
    }
  }

  Future<void> _handleRejectAction(
    BuildContext context,
    NotificationNotifier notifier,
    NotificationAction action,
    String callerKey,
  ) async {
    try {
      final personnelNotifier = context.read<PersonnelNotifier>();

      final success = await personnelNotifier.answerInvitation(
        ruleId: action.metadata['rule_id'],
        answer: 1,
        callerKey: callerKey,
      );

      if (success) {
        await notifier.markAsRead(action.notificationId);
        ResponseHandler.handleResponse(
          context: context,
          statusCode: 200,
          responseCode: 'INVITATION_REJECTED',
          finalMessage: 'Invitation rejected',
        );
        await _refreshNotifications();
      } else {
        final response = personnelNotifier.getResponse(callerKey);
        ResponseHandler.handleResponse(
          context: context,
          statusCode: response?.statusCode ?? 500,
          responseCode: response?.responseCode ?? 'REJECT_FAILED',
          finalMessage: response?.message ?? 'Failed to reject invitation',
        );
      }
    } catch (e) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 500,
        responseCode: 'REJECT_ERROR',
        finalMessage: 'Error rejecting invitation: $e',
      );
    }
  }

  void _handleViewAction(BuildContext context, NotificationAction action) {
    // Use safe navigation with proper argument handling
    final orgId = action.metadata['organization_id'] ?? 0;
    final providerId = action.metadata['provider_id'] ?? 0;
    final supplierName = action.metadata['supplier_name'] ?? '';

    Navigator.pushNamed(
      context,
      AppRoutes.supplierManage,
      arguments: {
        "supplierName": supplierName,
        "orgId": orgId is int ? orgId : int.tryParse(orgId.toString()) ?? 0,
        "supplierId": providerId is int
            ? providerId
            : int.tryParse(providerId.toString()) ?? 0,
      },
    );
  }

  Future<void> _handleDismissAction(
    BuildContext context,
    NotificationNotifier notifier,
    NotificationAction action,
    String callerKey,
  ) async {
    try {
      await notifier.markAsRead(action.notificationId, callerKey: callerKey);

      final response = notifier.getResponse(callerKey);
      ResponseHandler.handleResponse(
        context: context,
        statusCode: response?.statusCode ?? 200,
        responseCode: response?.responseCode ?? 'DISMISSED',
        finalMessage: 'Notification dismissed',
      );
    } catch (e) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 500,
        responseCode: 'DISMISS_ERROR',
        finalMessage: 'Error dismissing notification: $e',
      );
    }
  }

  Future<void> _handleReplyAction(
    BuildContext context,
    NotificationAction action,
    String callerKey,
  ) async {
    final TextEditingController controller = TextEditingController();

    final replyText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Type your reply...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (replyText != null && replyText.isNotEmpty) {
      // TODO: Implement reply API call
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 200,
        responseCode: 'REPLY_SENT',
        finalMessage: 'Reply sent successfully',
      );
    } else if (replyText == null) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 400,
        responseCode: 'REPLY_CANCELLED',
        finalMessage: 'Reply cancelled',
      );
    }
  }

  Future<void> _handleArchiveAction(
    BuildContext context,
    NotificationNotifier notifier,
    NotificationAction action,
    String callerKey,
  ) async {
    try {
      await notifier.deleteNotification(action.notificationId,
          callerKey: callerKey);

      final response = notifier.getResponse(callerKey);
      ResponseHandler.handleResponse(
        context: context,
        statusCode: response?.statusCode ?? 200,
        responseCode: response?.responseCode ?? 'ARCHIVED',
        finalMessage: 'Notification archived',
      );
    } catch (e) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 500,
        responseCode: 'ARCHIVE_ERROR',
        finalMessage: 'Error archiving notification: $e',
      );
    }
  }

  Future<void> _handleDownloadAction(
    BuildContext context,
    NotificationAction action,
    String callerKey,
  ) async {
    final url = action.metadata['url'];
    if (url == null) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 400,
        responseCode: 'NO_DOWNLOAD_URL',
        finalMessage: 'No download URL available',
      );
      return;
    }

    // TODO: Implement actual download logic
    ResponseHandler.handleResponse(
      context: context,
      statusCode: 200,
      responseCode: 'DOWNLOAD_STARTED',
      finalMessage: 'Download started',
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
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
            style: textTheme.titleMedium?.copyWith(
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
