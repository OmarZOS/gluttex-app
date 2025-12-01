import 'dart:convert';

import 'package:gluttex_core/app/Notifications/NotificationContent.dart';
import 'package:gluttex_core/app/Notifications/Notifications/RoleInvitation.dart';

class GluttexNotification {
  final int idNotification;
  final String notificationCode;
  final int notificationUserRef;
  final DateTime? notificationCreatedAt;
  final DateTime? notificationReadAt;
  final Map<String, dynamic> notificationParams;
  final NotificationContent? content;

  GluttexNotification({
    required this.idNotification,
    required this.notificationCode,
    required this.notificationUserRef,
    this.notificationCreatedAt,
    this.notificationReadAt,
    required this.notificationParams,
    this.content,
  });

  factory GluttexNotification.fromJson(Map<String, dynamic> json) {
    // Parse notification_params from JSON string to Map
    final paramsJson = json['notification_params'] as String? ?? '{}';
    final paramsMap = jsonDecode(paramsJson) as Map<String, dynamic>? ?? {};

    // Create appropriate NotificationContent based on notification_code
    NotificationContent? content;
    switch (json['notification_code']) {
      case 'role_invitation':
        content = RoleInvitation.fromJson(paramsMap);
        break;
      // Add more cases for other notification types here
      // case 'message':
      //   content = MessageNotification.fromJson(paramsMap);
      //   break;
      // case 'system_alert':
      //   content = SystemAlert.fromJson(paramsMap);
      //   break;
      default:
        content = null;
    }

    return GluttexNotification(
      idNotification: json['id_notification'] as int? ?? 0,
      notificationCode: json['notification_code'] as String? ?? '',
      notificationUserRef: json['notification_user_ref'] as int? ?? 0,
      notificationCreatedAt: json['notification_created_at'] != null
          ? DateTime.parse(json['notification_created_at'] as String)
          : null,
      notificationReadAt: json['notification_read_at'] != null
          ? DateTime.parse(json['notification_read_at'] as String)
          : null,
      notificationParams: paramsMap,
      content: content,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_notification': idNotification,
      'notification_code': notificationCode,
      'notification_user_ref': notificationUserRef,
      'notification_created_at': notificationCreatedAt?.toIso8601String(),
      'notification_read_at': notificationReadAt?.toIso8601String(),
      'notification_params': jsonEncode(notificationParams),
    };
  }

  // Helper getters
  bool get isRead => notificationReadAt != null;
  bool get hasContent => content != null;
  bool get requiresAction => content?.requiresAction ?? false;

  // Convenience getter for RoleInvitation (with type safety)
  RoleInvitation? get roleInvitation {
    if (content is RoleInvitation) {
      return content as RoleInvitation;
    }
    return null;
  }

  DateTime get effectiveDate => notificationCreatedAt ?? DateTime.now();

  @override
  String toString() {
    return 'Notification(id: $idNotification, code: $notificationCode, userRef: $notificationUserRef, read: $isRead, content: $content)';
  }

  GluttexNotification copyWith({
    int? idNotification,
    String? notificationCode,
    int? notificationUserRef,
    DateTime? notificationCreatedAt,
    DateTime? notificationReadAt,
    Map<String, dynamic>? notificationParams,
    NotificationContent? content,
  }) {
    return GluttexNotification(
      idNotification: idNotification ?? this.idNotification,
      notificationCode: notificationCode ?? this.notificationCode,
      notificationUserRef: notificationUserRef ?? this.notificationUserRef,
      notificationCreatedAt:
          notificationCreatedAt ?? this.notificationCreatedAt,
      notificationReadAt: notificationReadAt ?? this.notificationReadAt,
      notificationParams: notificationParams ?? this.notificationParams,
      content: content ?? this.content,
    );
  }

  GluttexNotification markAsRead() {
    return copyWith(notificationReadAt: DateTime.now());
  }

  GluttexNotification markAsUnread() {
    return copyWith(notificationReadAt: null);
  }
}
