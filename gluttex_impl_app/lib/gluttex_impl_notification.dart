import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Notifications/GluttexNotification.dart';
import 'package:gluttex_core/app/Notifications/NotificationList.dart';
import 'package:gluttex_core/app/Services/NotificationService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class GluttexImplNotification implements NotificationService {
  @override
  Future<NotificationList> getNotificationsByUserId(
    int userId, {
    int page = 1,
    int limit = 20,
  }) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    final result = await storageService.getAll(
      '${GluttexConstants.apiBaseUrl}${GluttexConstants.getNotificationsEndpoint}/${userId}/$page/$limit',
    );
    final NotificationList notificationList = NotificationList.fromJson(result);
    return notificationList;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    final result = storageService.update(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.putNotificationsEndpoint}/${notificationId}',
        notificationId.toString(), {}, {});
    // final GluttexNotification notification =
    //     GluttexNotification.fromJson(result);
    // return notification;
  }

  @override
  Future<void> markAllAsRead(int userId) async {
    // Your implementation
    throw UnimplementedError(
        'NotificationService.markAllAsRead not implemented');
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    // Your implementation
    throw UnimplementedError(
        'NotificationService.deleteNotification not implemented');
  }
}
