import '../../domain/entity/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.notificationId,
    required super.module,
    required super.eventType,
    required super.category,
    required super.title,
    required super.body,
    super.actionUrl,
    super.referenceType,
    super.referenceId,
    super.senderName,
    super.metadata,
    required super.read,
    super.createdDate,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      notificationId: json['notificationId']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      actionUrl: json['actionUrl']?.toString(),
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString(),
      senderName: json['senderName']?.toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      read: json['read'] == true,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
    );
  }
}
