import 'dart:developer';

import 'package:gluttex_core/app/Notifications/GluttexNotification.dart';
import 'package:gluttex_core/app/Notifications/NotificationContent.dart';
import 'package:gluttex_core/app/Notifications/Notifications/RoleInvitation.dart';

class NotificationList {
  final List<GluttexNotification> notifications;

  NotificationList(this.notifications);

  factory NotificationList.fromJson(List<dynamic> jsonList) {
    log("Getting notifications");
    final notifications = jsonList
        .map((json) =>
            GluttexNotification.fromJson(json as Map<String, dynamic>))
        .toList();
    return NotificationList(notifications);
  }

  List<GluttexNotification> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  List<GluttexNotification> get readNotifications =>
      notifications.where((n) => n.isRead).toList();

  List<GluttexNotification> get requiresActionNotifications =>
      notifications.where((n) => n.requiresAction).toList();

  // Get notifications by content type
  List<GluttexNotification> getRoleInvitations() {
    return notifications.where((n) => n.content is RoleInvitation).toList();
  }

  List<GluttexNotification> getByContentType<T extends NotificationContent>() {
    return notifications.where((n) => n.content is T).toList();
  }

  int get unreadCount => unreadNotifications.length;

  int get pendingActionCount => requiresActionNotifications.length;

  // Sort by date (newest first)
  List<GluttexNotification> get sortedByDate => List.from(notifications)
    ..sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));

  GluttexNotification? getNotificationById(int id) {
    try {
      return notifications.firstWhere((n) => n.idNotification == id);
    } catch (e) {
      return null;
    }
  }

  NotificationList markAllAsRead() {
    final updatedNotifications =
        notifications.map((n) => n.isRead ? n : n.markAsRead()).toList();
    return NotificationList(updatedNotifications);
  }

  NotificationList markAsRead(int id) {
    final updatedNotifications = notifications.map((n) {
      return n.idNotification == id ? n.markAsRead() : n;
    }).toList();
    return NotificationList(updatedNotifications);
  }

  NotificationList removeNotification(int id) {
    final updatedNotifications =
        notifications.where((n) => n.idNotification != id).toList();
    return NotificationList(updatedNotifications);
  }
}
