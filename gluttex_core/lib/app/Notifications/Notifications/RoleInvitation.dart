import 'dart:developer';

import 'package:gluttex_core/app/Notifications/NotificationContent.dart';

class RoleInvitation extends NotificationContent {
  final int organizationId;
  final int providerId;
  final int role;
  final int invitedBy;
  final int ruleId;

  RoleInvitation({
    required this.organizationId,
    required this.providerId,
    required this.role,
    required this.invitedBy,
    required this.ruleId,
    required DateTime timestamp,
  }) : super(
          type: 'role_invitation',
          timestamp: timestamp,
          addedBy: invitedBy,
        );

  factory RoleInvitation.fromJson(Map<String, dynamic> json) {
    return RoleInvitation(
      organizationId: json['organization_id'] as int? ?? 0,
      providerId: json['provider_id'] as int? ?? 0,
      role: json['role'] as int? ?? 0,
      invitedBy: json['invited_by'] as int? ?? 0,
      ruleId: json['rule_id'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  @override
  String get displayTitle => 'Role Invitation';

  // @override
  // String get displayMessage {
  //   final status = isPending
  //       ? 'pending'
  //       : isAccepted
  //           ? 'accepted'
  //           : 'rejected';
  //   return 'You have been invited to join a team with role $role (Status: $status)';
  // }

  // @override
  // String get actionText {
  //   // if (isPending) return 'Review Invitation';
  //   // if (isAccepted) return 'View Team';
  //   // return 'Dismiss';
  // }

  // @override
  // bool get requiresAction => isPending;

  // Business logic properties
  // bool get isPending => ruleType == 'PENDING';
  // bool get isAccepted => ruleType == 'ACCEPTED';
  // bool get isRejected => ruleType == 'REJECTED';

  RoleInvitation copyWith({
    int? ruleId,
    int? role,
    int? organizationId,
    int? providerId,
    DateTime? timestamp,
    int? invitedBy,
  }) {
    return RoleInvitation(
      ruleId: ruleId ?? this.ruleId,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      providerId: providerId ?? this.providerId,
      timestamp: timestamp ?? this.timestamp,
      invitedBy: invitedBy ?? this.invitedBy,
    );
  }

  // RoleInvitation markAsAccepted() {
  //   return copyWith(ruleType: 'ACCEPTED');
  // }

  // RoleInvitation markAsRejected() {
  //   return copyWith(ruleType: 'REJECTED');
  // }

  @override
  String toString() {
    return 'RoleInvitation(ruleId: $ruleId, role: $role)';
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement actionText
  String get actionText => throw UnimplementedError();

  @override
  // TODO: implement displayMessage
  String get displayMessage => throw UnimplementedError();

  @override
  // TODO: implement requiresAction
  bool get requiresAction => throw UnimplementedError();
}
