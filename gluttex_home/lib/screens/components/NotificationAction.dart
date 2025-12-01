import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_event/notification_notifier.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:provider/provider.dart';

enum ActionType {
  view,
  accept,
  reject,
  reply,
  dismiss,
  archive,
  download,
}

extension ActionTypeExt on ActionType {
  /// Convert enum to string "view", "accept", etc.
  String get value => name;

  /// Parse string to ActionType safely
  static ActionType fromString(String type) {
    return ActionType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ActionType.view,
    );
  }
}

class NotificationAction {
  final ActionType type;
  final String label;
  final int notificationId;
  final Map<String, dynamic> metadata;

  const NotificationAction({
    required this.type,
    required this.label,
    required this.notificationId,
    this.metadata = const {},
  });

  // ---------- JSON Helpers ----------
  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      type: ActionTypeExt.fromString(json['type']),
      label: json['label'] ?? '',
      notificationId: json['notificationId'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'label': label,
      'notificationId': notificationId,
      'metadata': metadata,
    };
  }

  // ---------- Convenience Constructors ----------
  factory NotificationAction.view(int id,
          {Map<String, dynamic> metadata = const {}}) =>
      NotificationAction(
          type: ActionType.view,
          label: "View",
          notificationId: id,
          metadata: metadata);

  factory NotificationAction.accept(int id,
          {Map<String, dynamic> metadata = const {}}) =>
      NotificationAction(
          type: ActionType.accept,
          label: "Accept",
          notificationId: id,
          metadata: metadata);

  factory NotificationAction.reject(int id,
          {Map<String, dynamic> metadata = const {}}) =>
      NotificationAction(
          type: ActionType.reject,
          label: "Reject",
          notificationId: id,
          metadata: metadata);

  factory NotificationAction.reply(int id,
          {String? text, Map<String, dynamic> metadata = const {}}) =>
      NotificationAction(
        type: ActionType.reply,
        label: "Reply",
        notificationId: id,
        metadata: {...metadata, if (text != null) 'text': text},
      );

  factory NotificationAction.dismiss(int id,
          {Map<String, dynamic> metadata = const {}}) =>
      NotificationAction(
          type: ActionType.dismiss,
          label: "Dismiss",
          notificationId: id,
          metadata: metadata);

  factory NotificationAction.archive(int id,
          {Map<String, dynamic> metadata = const {}}) =>
      NotificationAction(
          type: ActionType.archive,
          label: "Archive",
          notificationId: id,
          metadata: metadata);

  factory NotificationAction.download(int id,
          {String? url, Map<String, dynamic> metadata = const {}}) =>
      NotificationAction(
        type: ActionType.download,
        label: "Download",
        notificationId: id,
        metadata: {...metadata, if (url != null) 'url': url},
      );

  @override
  String toString() {
    return 'NotificationAction(type: $type, label: $label, id: $notificationId, metadata: $metadata)';
  }
}

class NotificationActionHandler {
  static Future<void> handle(
    BuildContext context,
    NotificationAction action,
  ) async {
    switch (action.type) {
      case ActionType.view:
        return _handleView(context, action);

      case ActionType.accept:
        return _handleAccept(context, action);

      case ActionType.reject:
        return _handleReject(context, action);

      case ActionType.reply:
        return _handleReply(context, action);

      case ActionType.dismiss:
        return _handleDismiss(context, action);

      case ActionType.archive:
        return _handleArchive(context, action);

      case ActionType.download:
        return _handleDownload(context, action);
    }
  }

  // ---------------- ACTION LOGIC ----------------

  static Future<void> _handleView(
      BuildContext context, NotificationAction action) async {
    Navigator.pushNamed(
      context,
      "/notification/${action.notificationId}",
    );
  }

  static Future<void> _handleAccept(
      BuildContext context, NotificationAction action) async {
    final _personnelNotifier = context.read<PersonnelNotifier>();
    final _notificationNotifier = context.read<NotificationNotifier>();
    log("Making it for : ${action.metadata['rule_id']}");
    final data =
        await _personnelNotifier.answerInvitation(action.metadata['rule_id']);
    print(data);
    if (data) {
      _notificationNotifier.markAsRead(action.notificationId);
    }
  }

  static Future<void> _handleReject(
      BuildContext context, NotificationAction action) async {
    final _personnelNotifier = context.read<PersonnelNotifier>();
    final _notificationNotifier = context.read<NotificationNotifier>();

    final data = await _personnelNotifier
        .answerInvitation(action.metadata['rule_id'], answer: 1);
    print(data);
    if (data) {
      _notificationNotifier.markAsRead(action.notificationId);
    }
  }

  static Future<void> _handleReply(
      BuildContext context, NotificationAction action) async {}

  static Future<void> _handleDismiss(
      BuildContext context, NotificationAction action) async {}

  static Future<void> _handleArchive(
      BuildContext context, NotificationAction action) async {}

  static Future<void> _handleDownload(
      BuildContext context, NotificationAction action) async {}
}
