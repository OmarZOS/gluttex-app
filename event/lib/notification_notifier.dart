import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:locator/locator.dart';

import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/Notifications/GluttexNotification.dart';
import 'package:gluttex_core/app/Notifications/NotificationContent.dart';
import 'package:gluttex_core/app/Notifications/NotificationList.dart';
import 'package:gluttex_core/app/Services/NotificationService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';

// ============ CACHE ENTRY WITH TTL ============
class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final int ttlSeconds;

  _CacheEntry(this.data, {this.ttlSeconds = 300}) : timestamp = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(timestamp).inSeconds > ttlSeconds;
  bool get isValid => !isExpired;
}

// ============ NOTIFICATION CHANGE NOTIFIER ============
class NotificationNotifier extends ChangeNotifier {
  final NotificationService _notificationService =
      AppLocator.get<NotificationService>();
  final StorageService _storageService = AppLocator.get<StorageService>();

  // ============ CACHE STORAGE ============
  final Map<int, GluttexNotification> _notificationCache = {};
  final Map<String, _CacheEntry<NotificationList>> _listCache = {};

  // LRU cache for frequently accessed notifications
  final LinkedHashMap<int, _CacheEntry<GluttexNotification>> _lruCache =
      LinkedHashMap();

  // Cache statistics
  int _cacheHits = 0;
  int _cacheMisses = 0;

  // Cache configuration
  static const int _maxCacheSize = 200;
  static const int _defaultCacheTTLSeconds = 300; // 5 minutes
  static const int _shortCacheTTLSeconds = 60; // 1 minute
  static const int _longCacheTTLSeconds = 3600; // 1 hour

  // Pagination constants
  static const int _itemsPerPage = 20;
  static const int _maxPageSize = 100;

  // Pagination state
  int _currentPage = 0;
  int _totalCount = 0;
  bool _hasMore = true;
  int _currentUserId = 0;
  bool _showOnlyUnread = false;

  // State management
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _error;

  // Batch request debouncing
  final Map<String, Future<NotificationList>> _pendingRequests = {};

  // Notification list cache keys
  String _getListCacheKey(int userId, int page, int limit, bool unreadOnly) {
    return 'notifications_${userId}_${page}_${limit}_${unreadOnly}';
  }

  NotificationNotifier();

  // ============ RESPONSE TRACKING HELPER METHODS ============

  String _generateCallerKey(String operation, {String? id, String? suffix}) {
    final parts = [operation];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    return parts.join('_');
  }

  void _storeSuccessResponse(String callerKey, dynamic data,
      {int? statusCode, String? responseCode}) {
    _storageService.setSuccessResponse(callerKey, data,
        statusCode: statusCode ?? 200, responseCode: responseCode);
    debugPrint('✅ Stored SUCCESS: $callerKey - $responseCode');
  }

  void _storeFailureResponse(String callerKey, dynamic data,
      {int? statusCode,
      String? errorCode,
      String? message,
      String? responseCode}) {
    _storageService.setFailureResponse(callerKey,
        data: data,
        statusCode: statusCode ?? 500,
        errorCode: errorCode,
        message: message,
        responseCode: responseCode);
    debugPrint('❌ Stored FAILURE: $callerKey - $responseCode');
  }

  // ============ LIFECYCLE ============

  @override
  void dispose() {
    _isDisposed = true;
    _clearAllCaches();
    _pendingRequests.clear();
    super.dispose();
  }

  // ============ CACHE MANAGEMENT ============

  void _clearAllCaches() {
    _notificationCache.clear();
    _lruCache.clear();
    _listCache.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  void _invalidateCache({int? notificationId, String? listKey}) {
    if (notificationId != null) {
      _notificationCache.remove(notificationId);
      _lruCache.remove(notificationId);
    }

    if (listKey != null) {
      _listCache.remove(listKey);
    }

    if (notificationId == null && listKey == null) {
      _clearAllCaches();
    }
  }

  void _addToLRUCache(int id, GluttexNotification notification) {
    if (_lruCache.containsKey(id)) {
      _lruCache.remove(id);
    }

    while (_lruCache.length >= _maxCacheSize) {
      final oldestKey = _lruCache.keys.first;
      _lruCache.remove(oldestKey);
    }

    _lruCache[id] =
        _CacheEntry(notification, ttlSeconds: _defaultCacheTTLSeconds);
  }

  GluttexNotification? _getFromLRUCache(int id) {
    final entry = _lruCache[id];
    if (entry == null) return null;

    if (entry.isExpired) {
      _lruCache.remove(id);
      _cacheMisses++;
      return null;
    }

    _lruCache.remove(id);
    _lruCache[id] = entry;

    _cacheHits++;
    return entry.data;
  }

  void _cacheList(String key, NotificationList list, {int? ttlSeconds}) {
    _listCache[key] =
        _CacheEntry(list, ttlSeconds: ttlSeconds ?? _defaultCacheTTLSeconds);

    // Cache individual notifications
    for (final notification in list.notifications) {
      _cacheNotification(notification);
    }
  }

  NotificationList? _getFromListCache(String key) {
    final entry = _listCache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _listCache.remove(key);
      _cacheMisses++;
      return null;
    }

    _cacheHits++;
    return entry.data;
  }

  void _cacheNotification(GluttexNotification notification, {int? ttlSeconds}) {
    final ttl = ttlSeconds ?? _defaultCacheTTLSeconds;
    _notificationCache[notification.idNotification] = notification;
    _addToLRUCache(notification.idNotification, notification);
  }

  GluttexNotification? _getCachedNotification(int id) {
    final lruCached = _getFromLRUCache(id);
    if (lruCached != null) return lruCached;

    final cached = _notificationCache[id];
    if (cached != null) {
      _addToLRUCache(id, cached);
      _cacheHits++;
      return cached;
    }

    _cacheMisses++;
    return null;
  }

  // ============ SAFE NOTIFICATION ============

  void _safeNotifyListeners() {
    if (!_isDisposed && hasListeners) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && hasListeners) {
          notifyListeners();
        }
      });
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      _safeNotifyListeners();
    }
  }

  // ============ PUBLIC GETTERS ============

  NotificationList get notifications => _notificationList;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get totalCount => _totalCount;
  String? get error => _error;
  int get unreadCount => _notificationList.unreadCount;
  int get pendingActionCount => _notificationList.pendingActionCount;

  NotificationList _notificationList = NotificationList(notifications: []);

  // ============ CACHE CONFIGURATION ============

  void invalidateCache({int? notificationId, String? listKey}) {
    _invalidateCache(notificationId: notificationId, listKey: listKey);
    _safeNotifyListeners();
  }

  void refreshAllCaches() {
    _clearAllCaches();
    _safeNotifyListeners();
  }

  // ============ NOTIFICATION FETCHING ============

  Future<void> loadInitialNotifications(
    int userId, {
    int limit = 20,
    bool unreadOnly = false,
    bool forceRefresh = false,
  }) async {
    final operationKey = _generateCallerKey('loadInitialNotifications',
        suffix: '${userId}_${limit}_${unreadOnly}');

    // Check cache
    if (!forceRefresh) {
      final cacheKey = _getListCacheKey(userId, 0, limit, unreadOnly);
      final cached = _getFromListCache(cacheKey);
      if (cached != null && cached.notifications.isNotEmpty) {
        _notificationList = cached;
        _currentPage = 1;
        _currentUserId = userId;
        _showOnlyUnread = unreadOnly;
        _totalCount = cached.totalCount;
        _hasMore = cached.notifications.length < cached.totalCount;
        _storeSuccessResponse(operationKey, cached,
            statusCode: 200, responseCode: 'CACHE_HIT');
        _safeNotifyListeners();
        return;
      }
    }

    if (_isLoading) {
      _storeFailureResponse(operationKey, null,
          statusCode: 429, errorCode: 'LOADING', responseCode: 'RATE_LIMITED');
      return;
    }

    _setLoading(true);
    _setError(null);
    _currentUserId = userId;
    _showOnlyUnread = unreadOnly;
    _currentPage = 0;

    try {
      final response = await _notificationService.getNotificationsByUserId(
        userId,
        page: 0,
        limit: limit,
        // unreadOnly: unreadOnly,
        callerKey: operationKey,
      );

      final statusCode = _storageService.getStatusCode(operationKey);
      final responseCode = _storageService.getResponseCode(operationKey);

      // Cache the result
      final cacheKey = _getListCacheKey(userId, 0, limit, unreadOnly);
      _cacheList(cacheKey, response, ttlSeconds: _shortCacheTTLSeconds);

      _notificationList = response;
      _currentPage = 1;
      _totalCount = response.totalCount;
      _hasMore = response.notifications.length < response.totalCount;

      _storeSuccessResponse(operationKey, response,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'SUCCESS');
      log('Loaded ${response.notifications.length} notifications for user $userId');
    } catch (e, stackTrace) {
      _setError('Failed to load notifications: $e');
      log('Error loading notifications: $e');
      log(stackTrace.toString());
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'LOAD_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreNotifications({int limit = 20}) async {
    if (_isLoading || !_hasMore) return;

    final operationKey = _generateCallerKey('loadMoreNotifications',
        suffix: '${_currentUserId}_${_currentPage}_${limit}');

    // Check cache for next page
    final cacheKey =
        _getListCacheKey(_currentUserId, _currentPage, limit, _showOnlyUnread);
    final cached = _getFromListCache(cacheKey);
    if (cached != null && cached.notifications.isNotEmpty) {
      final allNotifications = [
        ..._notificationList.notifications,
        ...cached.notifications,
      ];
      _notificationList = NotificationList(
        notifications: allNotifications,
        totalCount: cached.totalCount,
        unreadCount: allNotifications.where((n) => !n.isRead).length,
      );
      _currentPage++;
      _hasMore =
          _notificationList.notifications.length < _notificationList.totalCount;
      _storeSuccessResponse(operationKey, cached,
          statusCode: 200, responseCode: 'CACHE_HIT');
      _safeNotifyListeners();
      return;
    }

    _setLoading(true);

    try {
      final response = await _notificationService.getNotificationsByUserId(
        _currentUserId,
        page: _currentPage,
        limit: limit,
        // unreadOnly: _showOnlyUnread,
        callerKey: operationKey,
      );

      final statusCode = _storageService.getStatusCode(operationKey);
      final responseCode = _storageService.getResponseCode(operationKey);

      // Cache the result
      _cacheList(cacheKey, response, ttlSeconds: _shortCacheTTLSeconds);

      final allNotifications = [
        ..._notificationList.notifications,
        ...response.notifications,
      ];

      _notificationList = NotificationList(
        notifications: allNotifications,
        totalCount: response.totalCount,
        unreadCount: allNotifications.where((n) => !n.isRead).length,
      );
      _currentPage++;
      _hasMore =
          _notificationList.notifications.length < _notificationList.totalCount;

      _storeSuccessResponse(operationKey, response,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'SUCCESS');
      log('Loaded ${response.notifications.length} more notifications');
    } catch (e) {
      _setError('Failed to load more notifications: $e');
      log('Error loading more notifications: $e');
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'LOAD_MORE_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshNotifications(int userId,
      {int limit = 20, bool unreadOnly = false}) async {
    // Invalidate cache before refresh
    final cacheKey = _getListCacheKey(userId, 0, limit, unreadOnly);
    _invalidateCache(listKey: cacheKey);
    await loadInitialNotifications(userId,
        limit: limit, unreadOnly: unreadOnly, forceRefresh: true);
  }

  // ============ NOTIFICATION ACTIONS ============

  Future<void> markAsRead(int notificationId, {String? callerKey}) async {
    final operationKey = callerKey ??
        _generateCallerKey('markAsRead', id: notificationId.toString());

    if (_isLoading) {
      _storeFailureResponse(operationKey, null,
          statusCode: 429, errorCode: 'LOADING', responseCode: 'RATE_LIMITED');
      return;
    }

    _setLoading(true);

    try {
      await _notificationService.markAsRead(notificationId,
          callerKey: operationKey);

      final statusCode = _storageService.getStatusCode(operationKey);
      final responseCode = _storageService.getResponseCode(operationKey);

      // Update local state
      _notificationList = _notificationList.markAsRead(notificationId);
      _invalidateCache(notificationId: notificationId);

      _storeSuccessResponse(operationKey, true,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'SUCCESS');
      log('Marked notification $notificationId as read');
    } catch (e) {
      log('Error marking notification as read: $e');
      _setError('Failed to mark notification as read: $e');
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'MARK_READ_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAllAsRead({String? callerKey}) async {
    final operationKey = callerKey ??
        _generateCallerKey('markAllAsRead', id: _currentUserId.toString());

    if (_isLoading) {
      _storeFailureResponse(operationKey, null,
          statusCode: 429, errorCode: 'LOADING', responseCode: 'RATE_LIMITED');
      return;
    }

    _setLoading(true);

    try {
      await _notificationService.markAllAsRead(_currentUserId,
          callerKey: operationKey);

      final statusCode = _storageService.getStatusCode(operationKey);
      final responseCode = _storageService.getResponseCode(operationKey);

      // Update local state
      _notificationList = _notificationList.markAllAsRead();

      _storeSuccessResponse(operationKey, true,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'SUCCESS');
      log('Marked all notifications as read for user $_currentUserId');
    } catch (e) {
      log('Error marking all notifications as read: $e');
      _setError('Failed to mark all notifications as read: $e');
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'MARK_ALL_READ_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteNotification(int notificationId,
      {String? callerKey}) async {
    final operationKey = callerKey ??
        _generateCallerKey('deleteNotification', id: notificationId.toString());

    if (_isLoading) {
      _storeFailureResponse(operationKey, null,
          statusCode: 429, errorCode: 'LOADING', responseCode: 'RATE_LIMITED');
      return;
    }

    _setLoading(true);

    try {
      final success = await _notificationService.deleteNotification(
        notificationId,
        callerKey: operationKey,
      );

      final statusCode = _storageService.getStatusCode(operationKey);
      final responseCode = _storageService.getResponseCode(operationKey);

      // if (success) {
      //   // Update local state
      //   _notificationList =
      //       _notificationList.removeNotification(notificationId);
      //   _invalidateCache(notificationId: notificationId);
      //   _totalCount--;

      //   _storeSuccessResponse(operationKey, true,
      //       statusCode: statusCode ?? 200,
      //       responseCode: responseCode ?? 'SUCCESS');
      //   log('Deleted notification $notificationId');
      // } else {
      //   _storeFailureResponse(operationKey, false,
      //       statusCode: statusCode ?? 500,
      //       errorCode: 'DELETE_FAILED',
      //       message: 'Failed to delete notification',
      //       responseCode: 'ERROR');
      // }
    } catch (e) {
      log('Error deleting notification: $e');
      _setError('Failed to delete notification: $e');
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'DELETE_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
    } finally {
      _setLoading(false);
    }
  }

  // ============ HELPER METHODS ============

  void clearError() {
    _setError(null);
  }

  GluttexNotification? getNotificationById(int id) {
    return _getCachedNotification(id) ??
        _notificationList.getNotificationById(id);
  }

  // ============ FILTER METHODS ============

  List<GluttexNotification> get unreadNotifications =>
      _notificationList.unreadNotifications;

  List<GluttexNotification> get readNotifications =>
      _notificationList.readNotifications;

  List<GluttexNotification> get requiresActionNotifications =>
      _notificationList.requiresActionNotifications;

  List<GluttexNotification> get sortedByDate => _notificationList.sortedByDate;

  List<GluttexNotification> getRoleInvitations() =>
      _notificationList.getRoleInvitations();

  List<GluttexNotification> getByContentType<T extends NotificationContent>() =>
      _notificationList.getByContentType<T>();

  // ============ STATE RESET ============

  void reset() {
    _clearAllCaches();
    _notificationList = NotificationList(notifications: []);
    _currentPage = 0;
    _totalCount = 0;
    _hasMore = true;
    _isLoading = false;
    _error = null;
    _currentUserId = 0;
    _showOnlyUnread = false;
    _pendingRequests.clear();

    _safeNotifyListeners();
  }

  CallerResponse? getResponse(String callerKey) {
    return _storageService.getResponse(callerKey);
  }
}
