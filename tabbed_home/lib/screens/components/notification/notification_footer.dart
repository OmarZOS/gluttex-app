import 'package:flutter/material.dart';
import 'package:event/notification_notifier.dart';

class NotificationFooter extends StatelessWidget {
  final NotificationNotifier notifier;
  final int unreadCount;
  final VoidCallback onMarkAllRead;
  final VoidCallback onViewAll;

  const NotificationFooter({
    super.key,
    required this.notifier,
    required this.unreadCount,
    required this.onMarkAllRead,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed:
                  unreadCount > 0 && !notifier.isLoading ? onMarkAllRead : null,
              child: notifier.isLoading
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
              onPressed: notifier.isLoading ? null : onViewAll,
              child: const Text('View All'),
            ),
          ),
        ],
      ),
    );
  }
}
