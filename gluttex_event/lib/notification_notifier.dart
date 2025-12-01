import 'package:gluttex_core/app/Notifications/GluttexNotification.dart';
import 'package:gluttex_core/app/Notifications/NotificationContent.dart';
import 'package:gluttex_core/app/Notifications/NotificationList.dart';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/app/Services/NotificationService.dart';

import 'package:locator/locator.dart';

class NotificationNotifier with ChangeNotifier {
  final NotificationService _notificationService =
      GluttexLocator.get<NotificationService>();
  late int _userId;

  // State
  NotificationList _notifications = NotificationList([]);
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  int _totalCount = 0;
  String? _error;

  // NotificationNotifier();
  // Getters
  NotificationList get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get totalCount => _totalCount;
  String? get error => _error;
  int get unreadCount => _notifications.unreadCount;
  int get pendingActionCount => _notifications.pendingActionCount;

  // Load initial notifications
  Future<void> loadInitialNotifications(int userId, {int limit = 20}) async {
    _isLoading = true;
    _error = null;
    _userId = userId;
    notifyListeners();
    log("Loading initial notifications");
    try {
      final response = await _notificationService.getNotificationsByUserId(
        _userId,
        page: 0,
        limit: limit,
      );

      _notifications = response;
      final total = response.notifications.length;
      log("Got $total notifications");
      _totalCount = total;
      _currentPage++;
      _hasMore = _notifications.notifications.length < total;

      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      log(_error ?? "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more notifications (pagination)
  Future<void> loadMoreNotifications({int limit = 20}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();
    log("Loading more notifications");
    try {
      final response = await _notificationService.getNotificationsByUserId(
        _userId,
        page: _currentPage++,
        limit: limit,
      );

      final newNotifications = response;
      final total = response.notifications.length;

      // Merge with existing notifications
      final allNotifications = [
        ..._notifications.notifications,
        ...newNotifications.notifications,
      ];

      _notifications = NotificationList(allNotifications);
      _totalCount = total;
      _currentPage++;
      _hasMore = _notifications.notifications.length < total;

      _error = null;
    } catch (e) {
      _error = 'Failed to load more notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh notifications (pull to refresh)
  Future<void> refreshNotifications(int userId, {int limit = 20}) async {
    await loadInitialNotifications(userId, limit: limit);
  }

  // Mark a single notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      _notifications = _notifications.markAsRead(notificationId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead(_userId);

      // Update local state
      _notifications = _notifications.markAllAsRead();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark all notifications as read: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Update local state
      _notifications = _notifications.removeNotification(notificationId);
      _totalCount--;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete notification: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get notification by ID
  GluttexNotification? getNotificationById(int id) {
    return _notifications.getNotificationById(id);
  }

  // Filter methods that delegate to NotificationList
  List<GluttexNotification> get unreadNotifications =>
      _notifications.unreadNotifications;
  List<GluttexNotification> get readNotifications =>
      _notifications.readNotifications;
  List<GluttexNotification> get requiresActionNotifications =>
      _notifications.requiresActionNotifications;
  List<GluttexNotification> get sortedByDate => _notifications.sortedByDate;

  List<GluttexNotification> getRoleInvitations() =>
      _notifications.getRoleInvitations();
  List<GluttexNotification> getByContentType<T extends NotificationContent>() =>
      _notifications.getByContentType<T>();
}
